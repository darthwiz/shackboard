class Forum < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "forums"
  set_inheritance_column "_type"
  set_primary_key "fid"
  belongs_to :forum,  :foreign_key => 'fup'
  has_many   :topics, :foreign_key => 'fid', :dependent => :destroy
  has_many   :posts,  :foreign_key => 'fid', :dependent => :destroy
  @@tree = nil
  def container # {{{
    self.forum
  end # }}}
  def acl # {{{
    acl = AclMapping.map(self)
    return acl if acl
    acl = Acl.new
    acl.can_read(['User', :any]) if (allowed.empty? && self.private == '')
    acl.can_read(['User', :any]) if self[:type] == 'group' # XXX caution here
    (allowed + moderator_ids + User.supermods).each do |uid|
      uid = uid.id if uid.is_a? User
      acl.can_read(['User', uid])
      acl.can_moderate(['User', uid])
    end
    acl.save
    am = AclMapping.new
    am.associate(self, acl)
    am.save
    acl
  end # }}}
  def can_post?(user) # {{{
    # FIXME This is a very basic implementation, only meant to pass the basic
    # tests.
    if user.is_a? Array
      begin
        user = User.find(user[1]) if user[0] == 'User'
      rescue
        return false
      end
    end
    perms = self[:postperm].split('|')
    perms.each_with_index { |i, j| perms[j] = i.to_i }
    return true if (perms[0] == 1 && user.is_a?(User))
    return true if (perms[0] == 2 && self.acl.can_moderate?(user))
    return false
  end # }}}
  def moderators # {{{
    mods = []
    self.moderator.split(/,\s*/).each do |n|
      u = User.find_by_username(n.strip)
      mods << u unless u.nil?
    end
    mods
  end # }}}
  def moderator_ids # {{{
    mod_ids = []
    self.moderators.each { |u| mod_ids << u.id.to_i }
    mod_ids
  end # }}}
  def allowed # {{{
    users = []
    self.userlist.split(/,\s*/).each do |n|
      u = User.find_by_username(n.strip)
      users << u.id.to_i unless u.nil?
    end
    users
  end # }}}
  def children # {{{
    Forum.find(:all, :conditions => ['fup = ?', self.id],
                     :order      => 'displayorder')
  end # }}}
  def topics(range) # {{{
    raise TypeError, 'argument must be a Range' unless range.is_a? Range
    topics  = []
    seq     = range.begin
    conds   = ["fid = ?", self.fid]
    topics += Topic.find :all,
                         :conditions => conds,
                         :order      => 'topped DESC, lastpost DESC',
                         :offset     => range.begin,
                         :limit      => range.entries.length
    topics
  end # }}}
  def topics_count_cached # {{{
    self[:threads]
  end # }}}
  def posts_count_cached # {{{
    self[:posts]
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
  def Forum.tree(root=nil) # {{{
    return @@tree if (@@tree && root == nil)
    unless root.is_a? Forum
      root    = Forum.new
      root.id = 0
    end
    tree = []
    root.children.each do |f|
      tree << [f, Forum.tree(f)]
    end
    if root.id == 0
      tree = [[], tree]
      @@tree = tree unless @@tree
    end
    tree
  end # }}}
  def Forum.set_tree(tree=nil) # {{{
    @@tree = tree if tree.is_a? Array
  end # }}}
  def Forum.subtree(f, tree=Forum.tree) # {{{
    if tree[0] == f
      return [f, tree[1]]
    else
      tree[1].each do |t|
        r = Forum.subtree(f, t)
        return r if r[0] == f
      end
    end
  end # }}}
  def fix_counters # {{{
    self[:threads] = Forum.find(self.id).topics_count
    self[:posts]   = Forum.find(self.id).posts_count
    self.save
    [ self[:threads], self[:posts] ]
  end # }}}
  def latest_topics(n=5, parms={}) # {{{
    topics = Topic.find(:all,
               :conditions => ['fid = ? AND deleted IS NULL', self.id],
               :order      => 'lastpost DESC',
               :limit      => n
    )
    if parms[:include_sub]
      self.children.each do |f|
  if f.acl.can_read?(parms[:user])
    topics += Forum.latest_topics(f.id, n, :include_sub => true)
  end
      end
    end
    topics.sort! { |a, b| a.lastpost <=> b.lastpost }
    topics.reverse[0...n]
  end # }}}
  def Forum.latest_topics(id, *args) # {{{
    f = Forum.find(id)
    f.latest_topics(*args)
  end # }}}
  def move_to_sub(forum) # {{{
    raise ArgumentError unless forum.is_a? Forum
    self.fup = forum.id
    self[:type] = "sub"
    self.save
  end # }}}
end
