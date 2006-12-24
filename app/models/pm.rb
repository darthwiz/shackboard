class Pm < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "u2u"
  set_primary_key "u2uid"
  def Pm.unread_for(user) # {{{
    return nil unless user.is_a? User
    Pm.count(:conditions => ['msgto = ? AND status = ?', user.username, 'new'])
  end # }}}
  def from # {{{
    User.find_by_username(self.msgfrom) || User.new
  end # }}}
  def to # {{{
    User.find_by_username(self.msgto) || User.new
  end # }}}
  def read? # {{{
    self.status == 'read'
  end # }}}
  def Pm.count_from_to(from, to) # {{{
    raise TypeError unless from.is_a? User
    raise TypeError unless to.is_a? User
    conds = [ "msgfrom = ? AND msgto = ?", from.username, to.username ]
    Pm.count(:conditions => conds)
  end # }}}
end
