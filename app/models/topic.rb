class Topic < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "threads"
  set_primary_key "tid"
  belongs_to :forum, :foreign_key   => "fid", :dependent => :destroy,
                     :counter_cache => :threads
  has_many   :posts, :foreign_key   => "tid", :dependent => :destroy
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
    AclMapping.map(self) || self.container.acl
  end # }}}
  def user # {{{
    user = User.find_by_username(self.author)
    user = User.new unless user
    user
  end # }}}
def fix_counters # {{{
  self[:replies] = Topic.find(self.id).posts_count
  self.save
end # }}}
  def move_to(forum) # {{{
    raise ArgumentError, "argument is not a Forum" unless forum.is_a? Forum
    Post.update_all("fid = #{forum.fid}",
      "fid = #{self.fid} AND tid = #{self.id}")
    self.forum = forum
    self.save
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
    (time, username) = self[:lastpost].split(/\|/, 2)
    time             = Time.at(time.to_i)
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
end
