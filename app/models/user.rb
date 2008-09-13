class User < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "members"
  set_primary_key "uid"
  has_many :group_memberships
  has_many :groups, :through => :group_memberships
  has_many :smileys
  has_many :categories
  validates_uniqueness_of :username
  @@supermods = nil
  @@admins    = nil

  def rank 
    Rank.evaluate(self.postnum)
  end
 
  def auth(password) 
    password == self.password
  end
 
  def fix_counters 
    posts  = Post.count(:conditions => ['author = ?', self.username])
    topics = Topic.count(:conditions => ['author = ?', self.username])
    self.postnum = posts + topics
    self.save
  end
 
  def ppp
    nearest_multiple(self[:ppp], POST_BLOCK_SIZE)
  end

  def tpp
    nearest_multiple(self[:tpp], TOPIC_BLOCK_SIZE)
  end

  def in_group?(group)
    begin
      group.include?(self)
    rescue
      return false
    end
  end
 
  def is_adm?
    User.admin_ids.include? self.id
  end

  def is_supermod?
    return true if User.admin_ids.include? self.id
    User.supermod_ids.include? self.id
  end
 
  def banned?
    self.status == 'Banned'
  end

  def status=(status)
    @@admins    = nil if status == 'Administrator'
    @@supermods = nil if status == 'Super Moderator'
    super
  end

  def rename!(new_username) 
    if User.find_by_username(new_username)
      raise DuplicateUserError, "user #{new_username.inspect} already exists"
    else
      old_username  = self.username
      self.username = new_username
      self.save!
    end
    Pm.each_by_msgfrom(old_username) do |pm|
      pm.msgfrom = new_username
      pm.save_with_validation(false)
    end
    Pm.each_by_msgto(old_username) do |pm|
      pm.msgto = new_username
      pm.save_with_validation(false)
    end
    Post.each_by_author(old_username) do |p|
      p.author = new_username
      p.save_with_validation(false)
    end
    Topic.each_by_author(old_username) do |t|
      t.author = new_username
      t.save_with_validation(false)
    end
    true
  end
 
  def User.authenticate(username, password) 
    u = User.find_by_username(username)
    if (u) then
      if (u.password == password) then
        return u
      end
    end
    return nil
  end
 
  def User.supermods 
    return @@supermods if @@supermods
    mods  = []
    conds = "status = 'Super Moderator' OR status = 'Administrator'"
    User.find(:all, :conditions => conds).each { |u| mods << u }
    @@supermods = mods
  end
 
  def User.supermod_ids 
    ids = []
    User.supermods.each { |u| ids << u.id }
    ids
  end
 
  def User.admins 
    return @@admins if @@admins
    adms = []
    User.find(:all, :conditions => "status = 'Administrator'").each do |u|
      adms << u
    end
    @@admins = adms
  end
 
  def User.admin_ids 
    ids = []
    User.admins.each { |u| ids << u.id }
    ids
  end
  
  private
  def nearest_multiple(i, j)
    (i.to_f / j).round * j
  end
 
end

class UserError < StandardError; end
class DuplicateUserError < UserError; end
