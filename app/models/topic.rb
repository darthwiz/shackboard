class Topic < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "threads"
  set_primary_key "tid"
  belongs_to :forum, :foreign_key => "fid", :counter_cache => :threads
  belongs_to :user,  :foreign_key => "uid"
  has_many   :posts, :foreign_key => "tid"

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

  def fix_counters
    self[:replies] = self.posts_count
    self.save
  end

  def move_to(forum)
    raise ArgumentError, "argument is not a Forum" unless forum.is_a? Forum
    Post.update_all("fid = #{forum.fid}",
      "fid = #{self.fid} AND tid = #{self.id}")
    self.forum = forum
    self.save
  end

  def posts_count
    conds = [ "fid = ? AND tid = ? AND DELETED IS NULL", self.fid, self.id ]
    Post.count(:conditions => conds) + 1
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

  def lastpost(what=nil)
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

  def lastpost=(params)
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
    range.begin  = 0 if range.begin < 0
    if range.end >= range.begin
      conds  = ["tid = ? AND fid = ?", self.tid, self.fid]
      posts += Post.find :all,
                         :conditions => conds,
                         :order      => 'dateline',
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
      #puts smiley_hash.to_yaml
      posts.each do |p| 
        p.seq = seq
        seq += 1
        p.cached_has_blog = blog_hash[p.user_id] || false
        p.cached_smileys  = smiley_hash[0] + smiley_hash[p.user_id].to_a
        p.cached_online   = online.include?(p.user_id)
        p.cached_user     = user_hash[p.user_id]
        p.cached_can_read = false
        p.cached_can_edit = false
        p.cached_can_read = true if can_read
        p.cached_can_edit = true if (user.is_a?(User) && user.id == p.user_id)
        p.cached_can_read = true if can_moderate
        p.cached_can_edit = true if can_moderate
      end
    end
    posts
  end

  def format
    'bb'
  end

  def Topic.find(*args)
    opts  = args.extract_options!
    conds = opts[:conditions] ? opts[:conditions] : ''
    unless (opts[:with_deleted] || opts[:only_deleted])
      conds    += ' AND deleted_by IS NULL' if conds.is_a? String
      conds[0] += ' AND deleted_by IS NULL' if conds.is_a? Array
    end
    if (opts[:only_deleted])
      conds    += ' AND deleted_by IS NOT NULL' if conds.is_a? String
      conds[0] += ' AND deleted_by IS NOT NULL' if conds.is_a? Array
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

  def destroy
    self.posts_each do |p|
      p.destroy
    end
    begin
      u = User.find_by_username(self.author)
      u.postnum -= 1
      u.save
    rescue
    end
    super
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

end
