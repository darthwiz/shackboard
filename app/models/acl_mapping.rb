class AclMapping < ActiveRecord::Base
  belongs_to :acl
  def associate(object, acl) # {{{
    self.object_type = object.class.to_s
    self.object_id   = object.id.to_i
    self.acl         = acl
  end # }}}
  def associated_object # {{{
    Module.const_get(self[:object_type]).find(self[:object_id])
  end # }}}
  def AclMapping.map(object) # {{{
    am = AclMapping.find(:first,
                         :conditions => [ 'object_type = ? AND object_id = ?',
                           object.class.to_s, object.id ] )
    if (am)
      return am.acl
    else
      return nil
    end
  end # }}}
  def AclMapping.associate!(object, acl) # {{{
    am = AclMapping.new
    am.associate(object, acl)
    am.save
  end # }}}
end
