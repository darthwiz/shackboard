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
end
