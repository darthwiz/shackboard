class User < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "members"
  set_primary_key "uid"
  has_many :group_memberships
  has_many :groups, :through => :group_memberships
  validates_uniqueness_of :username
  @@supermods = nil
  @@admins    = nil
  def rank # {{{
    Rank.evaluate(self.postnum)
  end # }}}
  def auth(password) # {{{
    password == self.password
  end # }}}
  def fix_counters # {{{
    posts  = Post.count(:conditions => ['author = ?', self.username])
    topics = Topic.count(:conditions => ['author = ?', self.username])
    self.postnum = posts + topics
    self.save
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
    User.find(:all, :conditions => conds).each { |u| mods << u }
    @@supermods = mods
  end # }}}
  def User.supermod_ids # {{{
    ids = []
    User.supermods.each { |u| ids << u.id }
    ids
  end # }}}
  def User.admins # {{{
    return @@admins if @@admins
    adms = []
    User.find(:all, :conditions => "status = 'Administrator'").each do |u|
      adms << u
    end
    @@admins = adms
  end # }}}
  def User.admin_ids # {{{
    ids = []
    User.admins.each { |u| ids << u.id }
    ids
  end # }}}
end
