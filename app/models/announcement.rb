class Announcement < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name       ANNOUNCEDB_PREFIX + 'posts'
  establish_connection ANNOUNCEDB_CONN_PARAMS

  def Announcement.find_latest(n=5)
    Announcement.find(:all, :order => 'date DESC', :limit => n)
  end

  def user
    User.find_by_username(self.poster)
  end

  def time
    Time.at(self.date)
  end

  def can_edit?(user)
    user.is_adm?
  end

end
