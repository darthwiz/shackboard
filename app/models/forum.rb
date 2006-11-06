class Forum < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "forums"
  set_inheritance_column "_type"
  set_primary_key "fid"
  has_many :topics, :foreign_key   => 'fid', :dependent => :destroy
  has_many :posts,  :foreign_key   => 'fid', :dependent => :destroy
  attr_accessor :children
  def container # {{{
    begin
      Forum.find(self.fup)
    rescue
      return nil
    end
  end # }}}
  def acl_new # {{{
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
  def acl_old # {{{
    #AclMapping.map(self) || self.container.acl
    acl = Acl.new
    acl.can_read([User, :any]) if (allowed.empty? && self.private == '')
    (allowed + moderators + User.supermods).each do |uid|
      acl.can_read([User, uid])
    end
    acl
  end # }}}
  def acl # {{{
    acl_new
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
  def Forum.tree(root=nil) # {{{
    tree = []
    fup  = 0
    fup  = root.id if root.is_a? Forum
    Forum.find(:all, :conditions => ['fup = ?', fup],
                     :order      => 'displayorder'
    ).each do |f|
      tree << [f, Forum.tree(f)]
    end
    tree
  end # }}}
  def Forum.buildtree(root=nil) # {{{
    unless root.is_a? Forum
      root    = Forum.new 
      root.id = 0
    end
    root.children = []
    Forum.find(:all, :conditions => ['fup = ?', root.id],
                     :order      => 'displayorder'
    ).each do |f|
      root.children << f
      f.children = Forum.buildtree(f)
    end
    return root.children
  end # }}}
  def child # {{{
    Forum.find(:all, :conditions => ['fup = ?', self.id],
                     :order      => 'displayorder')
  end # }}}
  def fix_counters # {{{
    self[:threads] = Forum.find(self.id).topics_count
    self[:posts]   = Forum.find(self.id).posts_count
    self.save
    [ self[:threads], self[:posts] ]
  end # }}}
end
