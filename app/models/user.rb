class User < ActiveRecord::Base
  set_table_name table_name_prefix + "members"
  set_primary_key "uid"
  has_many :group_memberships
  has_many :groups, :through => :group_memberships
  has_many :smileys
  has_many :categories
  validates_uniqueness_of :username
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_each :username do |record, key, value|
    record.errors.add key, 'cannot be numeric'         if value =~ /^[0-9\s]+$/
    record.errors.add key, 'cannot begin with a space' if value =~ /^\s/
  end
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
    #nearest_multiple(self[:ppp], POST_BLOCK_SIZE)
    self[:ppp]
  end

  def tpp
    #nearest_multiple(self[:tpp], TOPIC_BLOCK_SIZE)
    self[:tpp]
  end

  def posts_per_day
    time = Time.now - Time.at(self.regdate)
    postnum.to_f * 3600 * 24 / time
  end

  def blogs
    Blog.find_all_by_user_id(self.id)
  end

  def has_blog?
    !self.blogs.empty?
  end

  def online?
    OnlineUser.online.include?(self)
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

  def avatar_size
    rw = self[:avatar_width].to_f          # real width
    rh = self[:avatar_height].to_f         # real height
    mw = self.class.max_avatar_width.to_f  # max width
    mh = self.class.max_avatar_height.to_f # max height
    rr = 1.0                               # real ratio
    rr = rw / rh if rw > 0 && rh > 0       # real ratio
    tw = rw                                # target width
    th = rh                                # target height
    if rw <= mw && rh <= mh
      (tw, th) = [ rw, rh ]
    else
      if rw > mw           # too wide?
        tw = mw
        th = tw / rr
        if th > mh         # still too high?
          th = mh
          tw = th * rr
        end
      else # rh > mh       # too high?
        th = mh
        tw = th * rr
        if tw > mw         # still too wide?
          tw = mw
          th = tw / rr
        end
      end
    end
    { :width => tw.to_i, :height => th.to_i }
  end

  def avatar_width
    self.avatar_size[:width]
  end

  def avatar_height
    self.avatar_size[:height]
  end
 
  def self.max_avatar_width
    150
  end

  def self.max_avatar_height
    150
  end

  def self.authenticate(username, password) 
    u = User.find_by_username(username)
    if (u) then
      if (u.password == password) then
        return u
      end
    end
    return nil
  end
 
  def self.supermods 
    return @@supermods if @@supermods
    mods  = []
    conds = "status = 'Super Moderator' OR status = 'Administrator'"
    User.find(:all, :conditions => conds).each { |u| mods << u }
    @@supermods = mods
  end
 
  def self.supermod_ids 
    User.supermods.collect(&:id)
  end
 
  def self.admins 
    return @@admins if @@admins
    @@admins = User.find(:all, :conditions => "status = 'Administrator'")
  end
 
  def self.admin_ids 
    User.admins.collect(&:id)
  end
  
  def self.pwgen
    `pwgen -1 --capitalize --numerals --ambiguous`.strip
  end
  private
  def nearest_multiple(i, j)
    (i.to_f / j).round * j
  end
 
end

class UserError < StandardError; end
class DuplicateUserError < UserError; end
