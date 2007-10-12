class Topic < ActiveRecord::Base
  require 'magic_fixes.rb'
  require 'each_by.rb'
  include ActiveRecord::MagicFixes
  include ActiveRecord::EachBy
  extend  ActiveRecord::EachBy
  set_table_name table_name_prefix + "threads"
  set_primary_key "tid"
  belongs_to :forum, :foreign_key => "fid", :counter_cache => :threads
  belongs_to :user,  :foreign_key => "uid"
  has_many   :posts, :foreign_key => "tid"
  def container
    Forum.find(self.fid)
  end
  def name
    self.subject
  end
  def title
    self.subject
  end
  def total_posts
    self.replies + 1
  end
  def acl
    acl = AclMapping.map(self)
    return acl if acl
    acl             = Acl.new
    acl.permissions = self.container.acl.permissions
    acl
  end
  def can_post?(user)
    self.forum.can_post?(user) && self.closed.empty?
  end
  def can_read?(user)
    self.acl.can_read?(user)
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
    self[:replies].to_i + 1
  end
  def posts_count_cached=(n)
    self[:replies] = n - 1
  end
  def views_count_cached
    self[:views].to_i
  end
  def posts_each(limit=50)
    total  = self.posts_count
    offset = 0
    prog   = Progress.new
    while offset <= total
      Post.find(:all,
        :order      => 'dateline', 
        :conditions => ['fid = ? AND tid = ?', self.fid, self.id],
        :offset     => offset,
        :limit      => limit
      ).each do |p|
        yield p
      end
      offset += limit
      prog.measure(total, offset)
    end
    nil
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
  def posts(range)
    raise TypeError, 'argument must be a Range' unless range.is_a? Range
    posts = []
    seq   = range.begin
    if range.begin == 0
      p = Post.new
      self.attribute_names.each do |a|
        p.send(a + '=', self.send(a)) if p.respond_to?(a + '=')
      end
      p.user = self.user
      posts << p
      range = (range.begin.succ..range.end)     if !range.exclude_end?
      range = (range.begin.succ..range.end - 1) if range.exclude_end?
    end
    if range.end >= range.begin
      conds  = ["tid = ? AND fid = ?", self.tid, self.fid]
      posts += Post.find :all,
                         :conditions => conds,
                         :order      => 'dateline',
                         :offset     => range.begin - 1,
                         :limit      => range.entries.length,
                         :include    => :user
    end
    posts.each { |p| p.seq = seq; seq += 1 }
    posts
  end
  def format
    'bb'
  end
  def Topic.find(*args)
    opts  = extract_options_from_args!(args)
    conds = opts[:conditions] ? opts[:conditions] : ''
    unless (opts[:with_deleted] || opts[:only_deleted])
      conds    += ' AND deleted IS NULL' if conds.is_a? String
      conds[0] += ' AND deleted IS NULL' if conds.is_a? Array
    end
    if (opts[:only_deleted])
      conds    += ' AND deleted IS NOT NULL' if conds.is_a? String
      conds[0] += ' AND deleted IS NOT NULL' if conds.is_a? Array
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
