class GroupMembership < ActiveRecord::Base
  belongs_to     :user
  belongs_to     :group
  def associate(group, user) # {{{
    raise ArgumentError, 'Argument is not a User' unless user.is_a? User
    raise ArgumentError, 'Argument is not a Group' unless
      group.is_a? Group
    self.user      = user
    self.username  = user.username
    self.group     = group
    self.groupname = group.name
  end # }}}
end
