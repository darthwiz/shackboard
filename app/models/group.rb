class Group < ActiveRecord::Base
  has_many :group_memberships
  has_many :users, :through => :group_memberships
  def associate!(user) # {{{
    raise ArgumentError, 'Argument is not a User' unless user.is_a? User
    m = GroupMembership.find(:first,
      :conditions => ['user_id = ? AND group_id = ?',
  user.id, self.id]
    )
    m = GroupMembership.new unless m
    m.associate(self, user)
    m.save
  end # }}}
  def remove!(user) # {{{
    raise ArgumentError, 'Argument is not a User' unless user.is_a? User
    m = GroupMembership.find(:first,
      :conditions => ['user_id = ? AND group_id = ?',
  user.id, self.id]
    )
    return false unless m
    m.destroy
  end # }}}
  def include?(user) # {{{
    arr = arg_to_array(user)
    raise TypeError, "Argument is not a User or a ['User', user.id] array" \
      unless arr[0] == 'User'
    case arr[1].class.to_s
    when 'Fixnum'
      userid = arr[1]
    when 'String'
      user   = User.find_by_username(arr[1])
      userid = user.id if user
      return false unless user
    else
      return false
    end
    m = GroupMembership.find_by_group_id_and_user_id(self.id, userid)
    return true if m.is_a? GroupMembership
    return false
  end # }}}
  def Group.include?(groupname, user) # {{{
    g = Group.find_by_name(groupname)
    return false unless g.is_a? Group
    g.include?(user)
  end # }}}
  def acl # {{{
    return @acl if @acl
    @acl = AclMapping.map(self)
    return @acl if @acl
    @acl = Acl.new.attach_to(self)
  end # }}}
  private
  def arg_to_array(arg) # {{{
    case arg.class.to_s
    when 'Array'
      arr = arg
    else
      arr = [ arg.class.to_s, arg.id ]
    end
  end # }}}
end
