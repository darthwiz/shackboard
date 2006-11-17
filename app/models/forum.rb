class Forum < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "forums"
  set_inheritance_column "_type"
  set_primary_key "fid"
  belongs_to :forum,  :foreign_key   => 'fup'
  has_many   :topics, :foreign_key   => 'fid', :dependent => :destroy
  has_many   :posts,  :foreign_key   => 'fid', :dependent => :destroy
  @@tree = nil
  def container # {{{
    self.forum
  end # }}}
  def acl # {{{
    acl = AclMapping.map(self)
    return acl if acl
    acl = Acl.new
    acl.can_read(['User', :any]) if (allowed.empty? && self.private == '')
    (allowed + moderators + User.supermods).each do |uid|
      acl.can_read(['User', uid])
    end
    acl.save
    am = AclMapping.new
    am.associate(self, acl)
    am.save
    acl
  end # }}}
  def moderators # {{{
    mods = []
    self.moderator.split(/,\s*/).each do |n|
      mods << User.find_by_username(n.strip).id.to_i
    end
    mods
  end # }}}
  def allowed # {{{
    users = []
    self.userlist.split(/,\s*/).each do |n|
      users << User.find_by_username(n.strip).id.to_i
    end
    users
  end # }}}
  def children # {{{
    Forum.find(:all, :conditions => ['fup = ?', self.id],
                     :order      => 'displayorder')
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
  def latest_topics(n=5) # {{{
    Topic.find(:all,
               :conditions => ['fid = ? AND deleted IS NULL', self.id],
               :order      => 'lastpost DESC',
               :limit      => n
    )
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
