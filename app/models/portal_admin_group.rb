class PortalAdminGroup < ActiveRecord::Base
  set_table_name 'portal_admin_groups'
  has_many	 :portal_admin_group_memberships
  has_many	 :users, :through => :portal_admin_group_memberships
  def associate!(user) # {{{
    raise ArgumentError, 'Argument is not a User' unless user.is_a? User
    m = PortalAdminGroupMembership.find(:first,
      :conditions => ['user_id = ? AND portal_admin_group_id = ?',
	user.id, self.id]
    )
    m = PortalAdminGroupMembership.new unless m
    m.associate(self, user)
    m.save
  end # }}}
  def remove!(user) # {{{
    raise ArgumentError, 'Argument is not a User' unless user.is_a? User
    m = PortalAdminGroupMembership.find(:first,
      :conditions => ['user_id = ? AND portal_admin_group_id = ?',
	user.id, self.id]
    )
    return false unless m
    m.destroy
  end # }}}
end
