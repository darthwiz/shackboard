class Group < ActiveRecord::Base
  has_many :group_memberships, :dependent => :destroy
  has_many :users, :through => :group_memberships
  validates_uniqueness_of :name
  def associate!(user)
    arr = object_to_array(user)
    return false unless arr[0] == 'User'
    m = GroupMembership.find(:first,
      :conditions => ['user_id = ? AND group_id = ?', arr[1], self.id]
    )
    return false if m
    m = GroupMembership.new
    m.associate(self, user)
    m.save
    m
  end

  def remove!(user)
    arr = object_to_array(user)
    return false unless arr[0] == 'User'
    m = GroupMembership.find(:first,
      :conditions => ['user_id = ? AND group_id = ?', arr[1], self.id]
    )
    return false unless m
    m.destroy
  end

  def include?(user)
    arr = object_to_array(user)
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
  end

  def Group.include?(group, user)
    g = Group.new.send(:object_to_object, group)
    return false unless g.is_a? Group
    g.include?(user)
  end

  def Group.associate!(group, user)
    g = Group.new.send(:object_to_object, group)
    g.associate!(user)
  end

  def Group.remove!(group, user)
    g = Group.new.send(:object_to_object, group)
    g.remove!(user)
  end

  def can_edit?(user)
    acl.can_edit?(user)
  end
  
  def can_edit(user)
    acl.can_edit(user)
  end
  
  def remove_can_edit(user)
    acl.remove_can_edit(user)
  end
  
  def acl_save
    acl.save
  end
  
  private
  def acl
    return @acl if @acl
    @acl = AclMapping.map(self)
    return @acl if @acl
    @acl = Acl.new.attach_to(self)
  end
  
  def object_to_array(obj)
    case obj.class.to_s
    when 'Array'
      arr = obj
    when 'NilClass'
      arr = [ 'User', nil ]
    else
      arr = [ obj.class.to_s, obj.id ]
    end
  end
  
  def object_to_object(obj)
    case obj.class.to_s
    when 'Array'
      case obj[1].class.to_s
      when 'Fixnum'
        return User.find(obj[1])  if obj[0] == 'User'
        return Group.find(obj[1]) if obj[0] == 'Group'
      when 'String'
        return User.find_by_username(obj[1]) if obj[0] == 'User'
        return Group.find_by_name(obj[1])    if obj[0] == 'Group'
      end
    when ('Group' or 'User')
      return obj
    end
    nil
  end
  
  def arg_to_group(arg)
    case arg.class.to_s
    when 'Fixnum'
      return Group.find(arg)
    when 'String'
      return Group.find_by_name(arg)
    when 'Group'
      return arg
    end
    nil
  end
end
