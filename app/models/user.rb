class User < ActiveRecord::Base
  set_table_name table_name_prefix + "members"
  set_primary_key "uid"
  has_many :group_memberships
  has_many :groups, :through => :group_memberships
  has_many :smileys
  has_many :categories
  has_many :blogs
  validates_uniqueness_of :username
  validates_uniqueness_of :email, :allow_nil => true
  validates_length_of :username, :minimum => 1
  validates_length_of :password, :minimum => 6,
    :unless => lambda { |user| user.password.nil? && user.fbid.to_i > 0 }
  validates_format_of :email,
    :with   => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    :unless => lambda { |user| user.email.nil? && user.fbid.to_i > 0 }
  validates_each :username do |record, key, value|
    record.errors.add key, :cannot_be_numeric       if value =~ /^[0-9\s]+$/
    record.errors.add key, :cannot_begin_with_space if value =~ /^\s/
  end
  alias_attribute :created_at, :regdate
  alias_attribute :website, :site
  alias_attribute :signature, :sig
  default_scope :conditions => { :deleted_at => nil }
  named_scope :with_blog, :joins => :blogs, :conditions => "#{Blog.table_name}.user_id IS NOT NULL"
  attr_accessor :ip
  @@supermods = nil
  @@admins    = nil

  def rank 
    Rank.evaluate(self.postnum)
  end
 
  def auth(password) 
    password == self.password
  end
 
  def anonymized?
    self.status == 'Anonymized'
  end

  def posts_per_day
    time = Time.now - Time.at(self.regdate)
    postnum.to_f * 3600 * 24 / time
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

  def is_mod?(forum=nil)
    if forum.is_a? Forum
      return true if self.moderates.include?(forum)
    else
      return true if self.is_supermod?
      return true unless self.moderates.empty?
    end
    false
  end
 
  def can_edit?(user)
    # Beware, this method really should be called "can_be_edited_by?" but is so
    # called for consistency with the same method in other objects.
    return false unless user.is_a? User
    return true if user == self
    return true if user.is_adm?
    false
  end

  def moderates
    Forum.find(:all, :conditions => [ 'moderator LIKE ?', "%#{self.username}%" ], :order => 'name').select do |f|
      f.moderator_usernames.include? self.username
    end
  end

  def banned?
    [ 'Banned', 'Anonymized' ].include? self.status
  end

  def status=(status)
    @@admins    = nil if status == 'Administrator'
    @@supermods = nil if status == 'Super Moderator'
    super
  end

  def fix_post_count!
    self.postnum = Post.count(:conditions => [ 'uid = ? AND deleted_by IS NULL', self.id ])
    self.save!
    self.postnum
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

  def avatar
    return self[:avatar] if self[:avatar] =~ /^http:\/\//
    nil
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
 
  def nuke!
    self.class.nuke!(self.id)
  end

  def self.nuke!(id)
    self.with_exclusive_scope do
      self.update_all("deleted_at = #{Time.now.to_i}", "uid = #{id.to_i}", :limit => 1)
    end
  end

  def self.max_avatar_width
    150
  end

  def self.max_avatar_height
    150
  end

  def self.[](id)
    self.with_exclusive_scope { self.find(id) }
  end

  def self.is_mod?(user)
    return false unless user.is_a? User
    user.is_mod?
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
  
  def self.anonymized_usernames
    self.with_exclusive_scope do
      self.find(
        :all,
        :conditions => [ "status = 'Anonymized' OR deleted_at IS NOT NULL" ],
        :select => :username
      ).collect(&:username)
    end
  end

  def self.pwgen
    `pwgen -1 --capitalize --numerals --ambiguous`.strip
  end

  def self.fix_post_count!
    utn = self.table_name
    ptn = Post.table_name
    ctn = 'tmp_user_posts_count'
    q1  = "CREATE TEMPORARY TABLE #{ctn} (
      SELECT uid, COUNT(1) AS posts_count FROM #{ptn}
      WHERE deleted_by IS NULL
      GROUP BY uid
    )"
    q2  = "UPDATE #{utn} u
      INNER JOIN #{ctn} c ON u.uid = c.uid
      SET u.postnum = c.posts_count"
    q3  = "DROP TABLE #{ctn}"
    self.connection.execute q1
    self.connection.execute q2
    self.connection.execute q3
  end

  private
  def nearest_multiple(i, j)
    (i.to_f / j).round * j
  end
 
end

class UserError < StandardError; end
class DuplicateUserError < UserError; end
