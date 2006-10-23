class Forum < ActiveRecord::Base
  set_table_name table_name_prefix + "forums"
  set_inheritance_column "_type"
  set_primary_key "fid"
  has_many :topics
  def container # {{{
    begin
      Forum.find(self.fup)
    rescue
      return nil
    end
  end # }}}
  def acl # {{{
    #AclMapping.map(self) || self.container.acl
    acl = Acl.new
    acl.can_read([User, :any]) if (allowed.empty? && self.private == '')
    (allowed + moderators + User.supermods).each do |uid|
      acl.can_read([User, uid])
    end
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
  def Forum.tree(root=nil) # {{{
    tree = []
    fup  = 0
    fup  = root.id if root.is_a? Forum
    Forum.find(:all, :conditions => ['fup = ?', fup],
                     :order      => 'displayorder'
    ).each do |f|
      tree << [f.id, Forum.tree(f)]
    end
    tree
  end # }}}
  def Forum.treedump(tree, indent=0) # {{{
    s = ""
    if (tree.is_a? Fixnum)
      s << "#{' '*indent}#{Forum.find(tree).name}\n"
      print s
    elsif (tree.is_a? Array)
      tree.each { |t| s << Forum.treedump(t, indent + 1) }
    end
    return s
  end # }}}
end
