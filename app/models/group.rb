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
end
