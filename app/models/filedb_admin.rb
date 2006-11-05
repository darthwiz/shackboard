class FiledbAdmin < ActiveRecord::Base
  set_table_name       FILEDB_PREFIX + 'admin'
  establish_connection FILEDB_CONN_PARAMS
  set_primary_key      'admin_id'
  def FiledbAdmin.is_adm?(user) # {{{
    case user.class.to_s
    when 'User'
      username = user.username
    when 'String'
      username = user
    else
      username = ''
    end
    return true if FiledbAdmin.find_by_admin_username(username)
    return false
  end # }}}
  def FiledbAdmin.make_adm(user) # {{{
    return nil if is_adm?(user)
    adm                = FiledbAdmin.new
    adm.admin_username = user.username
    adm.save
  end # }}}
end
