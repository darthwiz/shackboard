class User < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "members"
  set_primary_key "uid"
  has_many :group_memberships
  has_many :groups, :through => :group_memberships
  @@supermods = nil
  def rank # {{{
    Rank.evaluate(self.postnum)
  end # }}}
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
      mods << u
    end
    @@supermods = mods
  end # }}}
  def User.supermod_ids # {{{
    mod_ids = []
    User.supermods.each { |u| mod_ids << u.id }
    mod_ids
  end # }}}
end
