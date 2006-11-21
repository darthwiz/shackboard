class User < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "members"
  set_primary_key "uid"
  has_many :portal_admin_group_memberships
  has_many :portal_admin_groups, :through => :portal_admin_group_memberships
  @@supermods = nil
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
  def User.supermods # {{{
    return @@supermods if @@supermods
    mods  = []
    conds = "status = 'Super Moderator' OR status = 'Administrator'"
    User.find(:all, :conditions => conds).each do |u|
      mods << u.id
    end
    @@supermods = mods
  end # }}}
end
