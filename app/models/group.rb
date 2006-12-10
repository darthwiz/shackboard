class Group < ActiveRecord::Base
  has_many	 :group_memberships
  has_many	 :users, :through => :group_memberships
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
    raise ArgumentError, "Argument is not a User" unless user.is_a? User
    m = GroupMembership.find_by_group_id_and_user_id(self.id, user.id)
    return true if m.is_a? GroupMembership
    return false
  end # }}}
  def Group.include?(groupname, user) # {{{
    raise ArgumentError, "Argument is not a User" unless user.is_a? User
    g = Group.find_by_name(groupname)
    return false unless g.is_a? Group
    g.include?(user)
  end # }}}
end
