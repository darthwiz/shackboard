class OnlineUser < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "whosonline"
  belongs_to :user, :foreign_key => 'uid'
  #set_primary_key "username"
  #validates_uniqueness_of :username

  def self.touch(user, ip)
    raise TypeError unless user.is_a?(User) || user.nil?
    uid   = 0
    uid   = user.id unless user.nil?
    conds = sanitize_sql(["uid = %d AND ip = '%s'", uid, ip])
    self.delete_all(conds)
    ou      = self.new
    ou.uid  = uid
    ou.ip   = ip
    ou.time = Time.now.to_i
    ou.save
  end

  def self.cleanup(time=5.minutes)
    conds = sanitize_sql(["time < %s", Time.now.to_i - time])
    self.delete_all(conds)
  end

  def self.guests_count
    self.count(:conditions => 'uid = 0')
  end

  def self.online
    users = []
    self.find(
      :all, :joins => 'INNER JOIN xmb_members
        ON xmb_members.uid = xmb_whosonline.uid AND xmb_members.deleted_at IS NULL',
      :order => 'xmb_members.username'
    ).each do |ou|
      users << ou.user
      users.last.ip = ou.ip
    end
    users
  end

end
