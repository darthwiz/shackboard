class User < ActiveRecord::Base
  set_table_name table_name_prefix + "members"
  set_primary_key "uid"
  def auth(password) # {{{
    password == self.password
  end # }}}
  def User.authenticate(username, password) # {{{
    u = User.find_by_username(username)
    if (u) then
      if (u.password == password) then
        return u
      end
    end
    return nil
  end # }}}
end
