class Topic < ActiveRecord::Base
  set_primary_key "tid"
  belongs_to :forum, :foreign_key => "fid", :counter_cache => :threads
  belongs_to :user,  :foreign_key => "uid"
  has_many   :posts, :foreign_key => "tid"
  validates_format_of :subject, :with => /^[^\s]/
  attr_accessor :message
  default_scope :conditions => "#{self.table_name}.deleted_by IS NULL"
  acts_as_simply_taggable

  named_scope :before_time, lambda { |time|
    { :conditions => "dateline < #{time.to_i}" }
  }

  named_scope :with_last_post_time, lambda {
    pt = Post.table_name
    tt = self.table_name
    { 
      :select => "#{tt}.*, MAX(wlpt_p.dateline) AS last_post_time",
      :joins  => "INNER JOIN #{pt} AS wlpt_p ON wlpt_p.tid = #{tt}.tid",
      :group  => "wlpt_p.tid",
    }
  }

  named_scope :at_time, lambda { |time|
    pt = Post.table_name
    tt = self.table_name
    { 
      :select     => "#{tt}.*, MAX(at_p.dateline) AS last_post_time",
      :conditions => "#{tt}.dateline <= #{time.to_i}",
      :joins      => "INNER JOIN #{pt} AS at_p ON at_p.tid = #{tt}.tid
                        AND at_p.dateline <= #{time.to_i}
                        AND at_p.dateline >= #{(time - 1.month).to_i}",
      :group      => "at_p.tid",
    }
  }

  named_scope :ordered_by_real_last_post_time_desc, :order   => "last_post_time DESC"
  named_scope :including_forum,                     :include => :forum

  def pinned
    self[:topped] == 1
  end

  def pinned?
    self[:topped] == 1
  end

  def pinned=(status)
    self[:topped] = status ? 1 : 0
  end

  def locked
    self[:closed] == 'yes'
  end

  def locked?
    self[:closed] == 'yes'
  end

  def locked=(status)
    self[:closed] = status ? 'yes' : 'no'
  end

  def container
    Forum.find(self.fid)
  end

  def name
    self.subject
  end

  def title
    self.subject
  end

  def title=(s)
    self.subject = s
  end

  def total_posts
    self.replies
  end

  def can_post?(user)
    self.forum.can_post?(user) && !(self.locked?)
  end

  def can_read?(user)
    self.forum.can_read?(user)
  end

  def can_moderate?(user)
    self.forum.can_moderate?(user)
  end

  def can_tag?(user)
    self.forum.can_post?(user)
  end

  def can_edit?(user)
    return false unless user.is_a? User
    return true if self.forum.can_moderate?(user)
    return true if (self.uid == user.id) && (Time.now.to_i - self.dateline.to_i < Settings.edit_time_limit)
    return false
  end

  def can_delete?(user)
    return false unless user.is_a? User
    return true if self.forum.can_moderate?(user)
    can_edit = self.can_edit?(user)
    return false unless can_edit
    tn            = Post.table_name
    distinct_uids = self.posts.find(:all, :select => "#{tn}.uid", :group => :uid).collect(&:uid)
    only_poster   = distinct_uids.length == 1 && distinct_uids.first == user.id
    return can_edit && only_poster
  end

  def delete(by_whom)
    raise TypeError unless by_whom.is_a? User
    self.deleted_by = by_whom.id
    self.deleted_on = Time.now.to_i
    # NOTE what follows is a dirty trick to piggyback the number of posts
    # deleted for every user, in order to keep the counters in sync.
    tn            = Post.table_name
    distinct_uids = self.posts.find(:all, :select => "COUNT(1) AS pid, #{tn}.uid", :group => :uid)
    distinct_uids.each do |i|
      User.update_all("postnum = postnum - #{i.pid}", "uid = #{i.uid}", :limit => 1)
    end
    Post.update_all("deleted_on = #{self.deleted_on}, deleted_by = #{self.deleted_by}", "tid = #{self.tid}")
    self.save!
    forum = self.forum
    forum[:posts] -= distinct_uids.inject(0) { |sum, i| sum += i.pid }
    forum.save!
    forum.update_last_post! # OPTIMIZE
  end

  def fix_counters!
    self[:replies] = self.posts_count
    self.save
  end

  def update_last_post!(last=nil)
    last = Post.find(
      :first,
      :conditions => [ 'tid = ? AND deleted_by IS NULL', self.id ],
      :order      => 'dateline DESC'
    ) unless last.is_a?(Post)
    self[:lastpost] = "#{last.dateline.to_i}|#{last.user.username}"
    self.save!
  end

  def move_to(forum)
    raise ArgumentError, "argument is not a Forum" unless forum.is_a? Forum
    Post.update_all("fid = #{forum.fid}",
      "fid = #{self.fid} AND tid = #{self.id}")
    self.forum = forum
    self.save
  end

  def posts_count
    conds = [ "fid = ? AND tid = ? AND deleted_by IS NULL", self.fid, self.id ]
    Post.count(:conditions => conds)
  end

  def posts_count_cached
    self[:replies].to_i
  end

  def posts_count_cached=(n)
    self[:replies] = n
  end

  def views_count_cached
    self[:views].to_i
  end

  def latest_posts(n=10, seen_by_user=nil)
    rend   = self.posts_count_cached - 1
    rstart = [ rend - n, 0 ].max
    self.posts_range(rstart..rend, seen_by_user)
  end

  def last_post(what=nil)
    (timestamp, username) = self[:lastpost].split(/\|/, 2)
    time                  = Time.at(timestamp.to_i)
    case what
    when nil
      return self[:lastpost]
    when :username
      return username
    when :user
      return User.find_by_username(username)
    when :time
      return time
    else
      return nil
    end
  end

  def last_post=(params)
    user            = params[:user]
    return false unless user.is_a? User
    timestamp       = params[:timestamp]
    self[:lastpost] = "#{timestamp}|#{user.username}"
  end

  def actual
    begin
      if self.closed == "moved"
        return Topic.find(self.message.strip.to_i).actual 
      end
    rescue
      return nil
    end
    return self
  end

  def posts_range(range, seen_by_user=nil)
    raise TypeError, 'argument must be a Range' unless range.is_a? Range
    user         = seen_by_user
    posts        = []
    seq          = range.begin
    can_moderate = self.can_moderate?(user)
    can_read     = self.can_read?(user)
    smiley_hash  = {}
    blog_hash    = {}
    user_hash    = {}
    time_limit   = Settings.edit_time_limit
    range        = 0..(range.end) if range.begin < 0
    if range.end >= range.begin
      conds  = ["tid = ? AND fid = ?", self.tid, self.fid]
      posts += Post.find :all,
                         :conditions => conds,
                         :order      => 'dateline',
                         :include    => [ :votes ],
                         :offset     => range.begin,
                         :limit      => range.entries.length
      user_ids = posts.collect(&:uid).uniq
      users    = User.find(user_ids)
      smileys  = Smiley.find_all_by_user_id([0] + user_ids)
      blogs    = Blog.find_all_by_user_id(user_ids)
      online   = OnlineUser.online.collect(&:id).uniq
      smileys.each do |i|
        smiley_hash[i.user_id] ||= []
        smiley_hash[i.user_id] << i
      end
      users.each do |i|
        user_hash[i.id] ||= i
      end
      blogs.each do |i|
        blog_hash[i.user_id] ||= true
      end
      posts.each do |p| 
        p.seq = seq
        seq += 1
        p.cached_has_blog = blog_hash[p.user_id] || false
        p.cached_smileys  = smiley_hash[p.user_id].to_a + smiley_hash[0]
        p.cached_online   = online.include?(p.user_id)
        p.cached_user     = user_hash[p.user_id]
        p.cached_can_read = false
        p.cached_can_edit = false
        p.cached_can_read = true if can_read
        p.cached_can_edit = true if (user.is_a?(User) && user.id == p.user_id) && (Time.now.to_i - p.dateline < time_limit)
        p.cached_can_read = true if can_moderate
        p.cached_can_edit = true if can_moderate
      end
    end
    posts
  end

  def format
    'bb'
  end

  def self.secure_find(id, user=nil)
    topic = self.find(id)
    raise UnauthorizedError unless topic.can_read?(user)
    topic
  end

  def self.find(*args)
    tt    = self.table_name
    opts  = args.extract_options!
    conds = opts[:conditions] ? opts[:conditions] : ''
    unless (opts[:with_deleted] || opts[:only_deleted])
      conds    += " AND #{tt}.deleted_by IS NULL" if conds.is_a? String
      conds[0] += " AND #{tt}.deleted_by IS NULL" if conds.is_a? Array
    end
    if (opts[:only_deleted])
      conds    += " AND #{tt}.deleted_by IS NOT NULL" if conds.is_a? String
      conds[0] += " AND #{tt}.deleted_by IS NOT NULL" if conds.is_a? Array
    end
    conds.sub!(/^ AND /, '') if conds.is_a? String
    conds = nil if conds.empty?
    opts.delete(:with_deleted)
    opts.delete(:only_deleted)
    opts[:conditions] = conds
    validate_find_options(opts)
    set_readonly_option!(opts)
    case args.first
      when :first then find_initial(opts)
      when :all   then find_every(opts)
      else             find_from_ids(args, opts)
    end
  end

  def move_posts(start_seq, dest_topic)
    raise TypeError, 'argument 1 must be a sequence number' unless
      start_seq.is_a? Integer
    dest_topic = Topic.find(dest_topic) if dest_topic.is_a? Integer
    raise TypeError, 'argument 2 must be a topic or a valid topic id' unless
      dest_topic.is_a? Topic
    range = (start_seq...self.posts_count)
    posts = self.posts(range)
    posts.each do |p|
      p.topic = dest_topic
      p.fid   = dest_topic.fid
      p.save
    end
    [self, dest_topic].each do |t|
      t.posts_count_cached = t.posts_count
      lastseq              = t.posts_count_cached - 1
      range                = lastseq..lastseq
      last                 = t.posts(range)[0]
      t.lastpost           = { :user      => last.user,
                               :timestamp => last.timestamp }
      t.save
    end
  end

  def self.fix_post_count!
    ttn = self.table_name
    ptn = Post.table_name
    utn = User.table_name
    ctn = 'tmp_topic_posts_count'
    q1  = "CREATE TEMPORARY TABLE #{ctn} (
      SELECT tid, COUNT(1) AS posts_count FROM #{ptn} p
      INNER JOIN #{utn} u ON (u.uid = p.uid AND u.deleted_at IS NULL)
      WHERE deleted_by IS NULL
      GROUP BY tid
    )"
    q2  = "UPDATE #{ttn} t
      INNER JOIN #{ctn} c ON t.tid = c.tid
      SET t.replies = c.posts_count"
    q3  = "DROP TABLE #{ctn}"
    self.connection.execute q1
    self.connection.execute q2
    self.connection.execute q3
  end

  def self.update_votes_count!
    ttn = self.table_name
    vtn = Vote.table_name
    ptn = Post.table_name
    [
      "CREATE TEMPORARY TABLE tmp_topic_likes 
        SELECT t.tid AS topic_id, SUM(v.points) AS likes FROM #{vtn} v
        INNER JOIN #{ptn} p ON v.votable_id = p.pid
          AND v.votable_type = 'Post'
          AND v.points > 0
        INNER JOIN #{ttn} t ON p.tid = t.tid
        GROUP BY t.tid",
      "CREATE TEMPORARY TABLE tmp_topic_dislikes 
        SELECT t.tid AS topic_id, ABS(SUM(v.points)) AS dislikes FROM #{vtn} v
        INNER JOIN #{ptn} p ON v.votable_id = p.pid
          AND v.votable_type = 'Post'
          AND v.points < 0
        INNER JOIN #{ttn} t ON p.tid = t.tid
        GROUP BY t.tid",
      "ALTER TABLE tmp_topic_likes ADD PRIMARY KEY (topic_id)",
      "ALTER TABLE tmp_topic_dislikes ADD PRIMARY KEY (topic_id)",
      "UPDATE #{ttn} t INNER JOIN tmp_topic_likes v ON t.tid = v.topic_id SET t.likes = v.likes",
      "UPDATE #{ttn} t INNER JOIN tmp_topic_dislikes v ON t.tid = v.topic_id SET t.dislikes = v.dislikes",
      "UPDATE #{ttn} SET total_likes = likes - dislikes",
      "DROP TABLE tmp_topic_likes",
      "DROP TABLE tmp_topic_dislikes",
    ].each { |q| self.connection.execute(q) }
    true
  end

end
