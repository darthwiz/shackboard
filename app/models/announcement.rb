class Announcement < ActiveRecord::Base
  require 'strip_helper.rb'
  include ActiveRecord::StripHelper
  set_table_name       ANNOUNCEDB_PREFIX + 'posts'
  establish_connection ANNOUNCEDB_CONN_PARAMS
  def after_find # {{{
    strip_slashes
  end # }}}
  def Announcement.latest(n=5) # {{{
    Announcement.find(:all,
                      :order => 'date DESC',
                      :limit => n)
  end # }}}
end
