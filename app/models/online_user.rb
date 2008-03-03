class OnlineUser < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "whosonline"
  belongs_to :user, :foreign_key => 'uid'
  #set_primary_key "username"
  #validates_uniqueness_of :username
  def OnlineUser.touch(user, ip)
    raise TypeError unless user.is_a?(User) || user.nil?
    uid   = 0
    uid   = user.id unless user.nil?
    conds = sanitize_sql(["uid = %d AND ip = '%s'", uid, ip])
    OnlineUser.delete_all(conds)
    ou      = OnlineUser.new
    ou.uid  = uid
    ou.ip   = ip
    ou.time = Time.now.to_i
    ou.save
  end
  def OnlineUser.cleanup(time=5.minutes)
    conds = sanitize_sql(["time < %s", Time.now.to_i - time])
    OnlineUser.delete_all(conds)
  end
  def OnlineUser.guests_count
    conds = sanitize_sql(["uid = 0"])
    OnlineUser.count(conds)
  end
  def OnlineUser.online
    users = []
    OnlineUser.find(
      :all, :joins => 'INNER JOIN xmb_members
        ON xmb_members.uid = xmb_whosonline.uid',
      :order => 'xmb_members.username'
    ).each do |ou|
      users << ou.user
    end
    users
  end
end
