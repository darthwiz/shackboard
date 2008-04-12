class Announcement < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name       ANNOUNCEDB_PREFIX + 'posts'
  establish_connection ANNOUNCEDB_CONN_PARAMS
  def Announcement.latest(n=5)
    Announcement.find(:all,
                      :order => 'date DESC',
                      :limit => n)
  end
end
