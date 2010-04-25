class User < ActiveRecord::Base
  set_primary_key "uid"
  has_many :group_memberships
  has_many :groups, :through => :group_memberships
  has_many :smileys
  has_many :blogs
  has_many :topics, :foreign_key => :uid
  has_many :posts, :foreign_key => :uid
  has_many :notifications, :foreign_key => :recipient_id
  has_many :bans
  validates_uniqueness_of :username
  validates_uniqueness_of :email, :allow_nil => true
  validates_length_of :username, :minimum => 1
  validates_length_of :password, :minimum => 6,
    :unless => lambda { |user| user.password.blank? && user.fbid.to_i > 0 }
  validates_format_of :email,
    :with   => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    :unless => lambda { |user| user.email.nil? && user.fbid.to_i > 0 }
  validates_each :username do |record, key, value|
    record.errors.add key, :cannot_be_numeric       if value =~ /^[0-9\s]+$/
    record.errors.add key, :cannot_begin_with_space if value =~ /^\s/
  end
  alias_attribute :created_at, :regdate
  alias_attribute :signature, :sig
  attr_accessor :ip
  @@supermods = nil
  @@admins    = nil
  default_scope :conditions => { :deleted_at => nil }
  named_scope :registered_after, lambda { |time| { :conditions => [ 'regdate >= ?', time.to_i ] } }
  named_scope :registered_before, lambda { |time| { :conditions => [ 'regdate < ?', time.to_i ] } }
  named_scope :with_blog, :joins => :blogs, :conditions => "#{Blog.table_name}.user_id IS NOT NULL"

  named_scope :banned_from_forum_at_time, lambda { |forum, time|
    raise TypeError unless forum.is_a?(Forum)
    raise TypeError unless time.is_a?(Time)
    ft = Forum.table_name
    bt = Ban.table_name
    ut = self.table_name
    {
      :select     => "#{ut}.uid, #{ut}.username, bf_b.id AS ban_id",
      :joins      => "INNER JOIN #{bt} AS bf_b ON #{ut}.uid = bf_b.user_id AND bf_b.forum_id = #{forum.id}",
      :conditions => [ "bf_b.created_at <= ? AND bf_b.expires_at >= ?", time, time ],
    }
  }

  def website
    return nil if self[:site].blank?
    self[:site] =~ /^https?:\/\// ? self[:site] : 'http://' + self[:site]
  end

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
    Forum.all.select { |f| f.moderator_usernames.include?(self.username) }
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

  def self.reset_cache!
    @@admins    = nil
    @@supermods = nil
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

  def self.update_karma!
    utn = self.table_name
    vtn = Vote.table_name
    ptn = Post.table_name
    [
      # create the temporary table
      "CREATE TEMPORARY TABLE tmp_karma (
        user_id INT NOT NULL,
        likes INT NOT NULL DEFAULT 0,
        dislikes INT NOT NULL DEFAULT 0,
        own_likes INT NOT NULL DEFAULT 0,
        own_dislikes INT NOT NULL DEFAULT 0,
        PRIMARY KEY (user_id)
      )",
      # fill it up with the active user ids
      "INSERT INTO tmp_karma
        SELECT uid AS user_id, 0, 0, 0, 0 FROM #{utn}
        WHERE deleted_at IS NULL",
      # count each user's own likes (except self-assigned)
      "CREATE TEMPORARY TABLE tmp_own_likes
        SELECT k.user_id, COUNT(1) AS own_likes FROM tmp_karma k
          LEFT JOIN #{vtn} v ON v.user_id = k.user_id
          INNER JOIN #{ptn} p ON v.votable_id = p.pid
            AND v.votable_type = 'Post'
            AND v.user_id != p.uid
            AND v.points > 0
          GROUP BY v.user_id",
      # count each user's own dislikes (except self-assigned)
      "CREATE TEMPORARY TABLE tmp_own_dislikes
          SELECT k.user_id, COUNT(1) AS own_dislikes FROM tmp_karma k
          LEFT JOIN #{vtn} v ON v.user_id = k.user_id
          INNER JOIN #{ptn} p ON v.votable_id = p.pid
            AND v.votable_type = 'Post'
            AND v.user_id != p.uid
            AND v.points < 0
          GROUP BY v.user_id",
      # count the likes each user received (except self-assigned)
      "CREATE TEMPORARY TABLE tmp_likes
        SELECT p.uid AS user_id, COUNT(1) AS likes FROM tmp_karma k
          LEFT JOIN #{vtn} v ON v.user_id = k.user_id
          INNER JOIN #{ptn} p ON v.votable_id = p.pid
            AND v.votable_type = 'Post'
            AND v.user_id != p.uid
            AND v.points > 0
          GROUP BY p.uid",
      # count the dislikes each user received (except self-assigned)
      "CREATE TEMPORARY TABLE tmp_dislikes
        SELECT p.uid AS user_id, COUNT(1) AS dislikes FROM tmp_karma k
          LEFT JOIN #{vtn} v ON v.user_id = k.user_id
          INNER JOIN #{ptn} p ON v.votable_id = p.pid
            AND v.votable_type = 'Post'
            AND v.user_id != p.uid
            AND v.points < 0
          GROUP BY p.uid",
      # optimize the stuff
      "ALTER TABLE tmp_own_likes ADD PRIMARY KEY (user_id)",
      "ALTER TABLE tmp_own_dislikes ADD PRIMARY KEY (user_id)",
      "ALTER TABLE tmp_likes ADD PRIMARY KEY (user_id)",
      "ALTER TABLE tmp_dislikes ADD PRIMARY KEY (user_id)",
      # merge the results
      "UPDATE tmp_karma k INNER JOIN tmp_own_likes v ON k.user_id = v.user_id SET k.own_likes = v.own_likes",
      "UPDATE tmp_karma k INNER JOIN tmp_own_dislikes v ON k.user_id = v.user_id SET k.own_dislikes = v.own_dislikes",
      "UPDATE tmp_karma k INNER JOIN tmp_likes v ON k.user_id = v.user_id SET k.likes = v.likes",
      "UPDATE tmp_karma k INNER JOIN tmp_dislikes v ON k.user_id = v.user_id SET k.dislikes = v.dislikes",
      # do the grand calculations
      # clean up everything
      "DROP TABLE tmp_own_likes",
      "DROP TABLE tmp_own_dislikes",
      "DROP TABLE tmp_likes",
      "DROP TABLE tmp_dislikes",
      "DROP TABLE tmp_karma",
    ].collect { |q| q.gsub(/\s+/, ' ') }
  end

  private
  def nearest_multiple(i, j)
    (i.to_f / j).round * j
  end

end

class UserError < StandardError; end
class DuplicateUserError < UserError; end
