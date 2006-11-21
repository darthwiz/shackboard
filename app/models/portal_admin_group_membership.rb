class PortalAdminGroupMembership < ActiveRecord::Base
  set_table_name 'portal_admin_group_memberships'
  belongs_to     :user
  belongs_to     :portal_admin_group
  def associate(group, user) # {{{
    raise ArgumentError, 'Argument is not a User' unless user.is_a? User
    raise ArgumentError, 'Argument is not a PortalAdminGroup' unless
      group.is_a? PortalAdminGroup
    self.user               = user
    self.username           = user.username
    self.portal_admin_group = group
    self.groupname          = group.name
  end # }}}
end
