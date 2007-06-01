class Topic < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "threads"
  set_primary_key "tid"
  belongs_to :forum, :foreign_key => "fid", :counter_cache => :threads
  has_many   :posts, :foreign_key => "tid" #, :dependent     => :destroy
  def container # {{{
    Forum.find(self.fid)
  end # }}}
  def name # {{{
    self.subject
  end # }}}
  def title # {{{
    self.subject
  end # }}}
  def total_posts # {{{
    self.replies + 1
  end # }}}
  def acl # {{{
    acl = AclMapping.map(self)
    return acl if acl
    acl             = Acl.new
    acl.permissions = self.container.acl.permissions
    acl
  end # }}}
  def can_post?(user) # {{{
    self.forum.can_post?(user)
  end # }}}
  def can_read?(user) # {{{
    self.acl.can_read?(user)
  end # }}}
  def user # {{{
    user = User.find_by_username(self.author)
    user = User.new unless user
    user
  end # }}}
def fix_counters # {{{
  self[:replies] = self.posts_count
  self.save
end # }}}
  def move_to(forum) # {{{
    raise ArgumentError, "argument is not a Forum" unless forum.is_a? Forum
    Post.update_all("fid = #{forum.fid}",
      "fid = #{self.fid} AND tid = #{self.id}")
    self.forum = forum
    self.save
  end # }}}
  def posts_count # {{{
    conds = [ "fid = ? AND tid = ? AND DELETED IS NULL", self.fid, self.id ]
    Post.count(:conditions => conds)
  end # }}}
  def posts_count_cached # {{{
    self[:replies].to_i + 1
  end # }}}
  def views_count_cached # {{{
    self[:views].to_i
  end # }}}
  def posts_each(limit=50) # {{{
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
  end # }}}
  def lastpost(what=nil) # {{{
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
  end # }}}
  def lastpost=(params) # {{{
    user            = params[:user]
    return false unless user.is_a? User
    timestamp       = params[:timestamp]
    self[:lastpost] = "#{timestamp}|#{user.username}"
  end # }}}
  def actual # {{{
    begin
      return Topic.find(self.message.strip.to_i).actual \
        if self.closed == "moved"
      rescue
        return nil
      end
    return self
  end # }}}
  def posts(range) # {{{
    raise TypeError, 'argument must be a Range' unless range.is_a? Range
    posts = []
    seq   = range.begin
    if range.begin == 0
      p = Post.new
      self.attribute_names.each do |a|
        p.send(a + '=', self.send(a)) if p.respond_to?(a + '=')
      end
      posts << p
      range = (range.begin.succ..range.end)  if !range.exclude_end?
      range = (range.begin.succ...range.end) if range.exclude_end?
    end
    if range.end > range.begin
      conds  = ["tid = ? AND fid = ?", self.tid, self.fid]
      posts += Post.find :all,
                         :conditions => conds,
                         :order      => 'dateline',
                         :offset     => range.begin - 1,
                         :limit      => range.entries.length
    end
    posts.each { |p| p.seq = seq; seq += 1 }
    posts
  end # }}}
  def format # {{{
    'bb'
  end # }}}
  def Topic.find(*args) # {{{
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
  end # }}}
  def destroy # {{{
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
  end # }}}
  def Topic.method_missing(method, *args, &block) # {{{
    begin
      super
    rescue Exception => e
      if method.to_s =~ /^each_by_/
        field = method.to_s.sub(/^each_by_/, '').to_sym
        return Topic.each_by_field(field, args, &block)
      else
        raise e
      end
    end
  end # }}}
  private
  def Topic.each_by_field(field, args) # {{{
    value = args.first
    case field
      when :author   then field = 'author'
      when :username then field = 'author'
      else raise InvalidFieldError, "invalid field #{field.inspect}"
    end
    conds  = [ "#{field} = ?", value ]
    count  = Topic.count(:conditions => conds)
    offset = 0
    limit  = 50
    while offset <= count
      Topic.find(
        :all,
        :conditions => conds,
        :offset     => offset,
        :limit      => limit
      ).each { |p| yield p }
      offset += limit
    end
    nil
  end # }}}
end

class InvalidFieldError < StandardError; end
