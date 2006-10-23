class AclMapping < ActiveRecord::Base
  belongs_to :acl
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
end
