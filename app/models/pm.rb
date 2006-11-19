class Pm < ActiveRecord::Base
  set_table_name table_name_prefix + "u2u"
  set_primary_key "u2uid"
  def Pm.unread_for(user) # {{{
    return nil unless user.is_a? User
    Pm.count(:conditions => ['msgto = ? AND status = ?', user.username, 'new'])
  end # }}}
end
