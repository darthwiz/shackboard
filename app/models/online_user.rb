class OnlineUser < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "whosonline"
  @@guest  = 'xguest123'
  @@record = 'onlinerecord'
  #belongs_to :user, :foreign_key => 'username'
  #set_primary_key "username"
  #validates_uniqueness_of :username
  def OnlineUser.touch(user, ip)
    raise TypeError unless user.is_a?(User) || user.nil?
    username = user.username unless user.nil?
    raise if [@@guest, @@record].include? username
    username = @@guest if user.nil?
    conds    = sanitize_sql(["username = '%s' AND ip = '%s'", username, ip])
    OnlineUser.delete_all(conds)
    ou          = OnlineUser.new
    ou.username = username
    ou.ip       = ip
    ou.time     = Time.now.to_i
    ou.save
  end
  def OnlineUser.cleanup(time=5.minutes)
    conds = sanitize_sql(["username != '%s' AND time < %s", @@record,
      Time.now.to_i - time])
    OnlineUser.delete_all(conds)
  end
  def OnlineUser.guests_count
    conds = sanitize_sql(["username LIKE '%s'", @@guest])
    OnlineUser.count(conds)
  end
  def OnlineUser.online
    users = []
    OnlineUser.find(
      :all, :joins => 'LEFT JOIN xmb_members
        ON xmb_members.username = xmb_whosonline.username',
      :order => 'xmb_members.username'
    ).each do |ou|
      unless [@@guest, @@record, nil].include? ou.username
        u          = User.new
        u.username = ou.username
        u.id       = ou.uid
        users << u
      end
    end
    users
  end
end
