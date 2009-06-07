class Forum < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_table_name table_name_prefix + "forums"
  set_inheritance_column "_type"
  set_primary_key "fid"
  belongs_to :forum,  :foreign_key => 'fup'
  has_many   :topics, :foreign_key => 'fid'
  has_many   :posts,  :foreign_key => 'fid'
  alias_attribute :posts_count, :posts
  @@tree = nil

  def container
    self.forum
  end

  def can_read?(user)
    userid = user.id if user.is_a? User
    userid = user[1] if user.is_a? Array
    return true if (allowed.empty? && self.private == '')
    return true if allowed.include?(userid)
    return true if moderator_ids.include?(userid)
    User.supermods.each do |u|
      return true if u.id == userid
    end
    false
  end

  def can_post?(user)
    # FIXME This is a very basic implementation, only meant to pass the basic
    # tests.
    return false if user.nil?
    return false if self.banned?(user)
    if user.is_a? Array
      begin
        user = User.find(user[1]) if user[0] == 'User'
      rescue
        return false
      end
    end
    perms = self[:postperm].split('|')
    perms.each_with_index { |i, j| perms[j] = i.to_i }
    return true if (perms[0] == 1 && user.is_a?(User))
    return true if (perms[0] == 2 && self.can_moderate?(user))
    return false
  end

  def can_moderate?(user)
    return false unless user.is_a? User
    return true if self.moderator_ids.include? user.id
    return true if User.supermod_ids.include? user.id
    return true if User.admin_ids.include? user.id
    return false
  end

  def banned?(user)
    user.banned?
  end

  def topics_range(range, seen_by_user=nil)
    raise TypeError, 'argument must be a Range' unless range.is_a? Range
    user         = seen_by_user
    topics       = []
    seq          = range.begin
    can_moderate = self.can_moderate?(user)
    can_read     = self.can_read?(user)
    user_hash    = {}
    range        = 0..(range.end) if range.begin < 0
    if range.end >= range.begin
      conds   = ["fid = ? AND deleted_by IS NULL", self.fid]
      topics += Topic.find :all,
                           :conditions => conds,
                           :order      => 'topped DESC, lastpost DESC',
                           :offset     => range.begin,
                           :limit      => range.entries.length
    end
    topics
  end

  def moderators
    mods = []
    self.moderator_usernames.each do |n|
      u = User.find_by_username(n.strip)
      mods << u unless u.nil?
    end
    mods
  end

  def moderator_usernames
    self.moderator.split(/,\s*/)
  end

  def moderator_ids
    mod_ids = []
    self.moderators.each { |u| mod_ids << u.id.to_i }
    mod_ids
  end

  def allowed
    users = []
    self.userlist.split(/,\s*/).each do |n|
      u = User.find_by_username(n.strip)
      users << u.id.to_i unless u.nil?
    end
    users
  end

  def add_child(forum)
    @children = [] if @children.nil?
    @children << forum
    @children.sort! { |a, b| a.displayorder.to_i <=> b.displayorder.to_i }
  end

  def children_cached
    @children = [] unless @children
    @children
  end

  def children
    unless @@tree
      @@tree = {}
      forums = Forum.find(:all)
      forums.each do |f|
        @@tree[f.id] = f
      end
      @@tree.each_pair do |id, f|
        if f.fup.to_i > 0
          @@tree[f.fup.to_i].add_child(f)
        end
      end
    end
    @@tree[self.id].children_cached
  end

  def topics(range)
    raise TypeError, 'argument must be a Range' unless range.is_a? Range
    topics  = []
    seq     = range.begin
    conds   = ["fid = ?", self.fid]
    topics += Topic.find :all,
                         :conditions => conds,
                         :order      => 'topped DESC, lastpost DESC',
                         :offset     => range.begin,
                         :limit      => range.entries.length
    topics
  end

  def topics_count_cached
    self[:threads]
  end

  def posts_count_cached
    self[:posts]
  end

  def last_post(what=nil)
    (time, username) = self[:lastpost].split(/\|/, 2)
    time             = Time.at(time.to_i)
    case what
    when nil
      return self[:lastpost]
    when :username
      return username
    when :user
      return User.find_by_username(username)
    when :time
      return time
    else
      return nil
    end
  end

  def update_last_post!
    last = Post.find(
      :first,
      :conditions => [ 'fid = ? AND deleted_by IS NULL', self.id ],
      :order      => 'dateline DESC'
    )
    self[:lastpost] = "#{last.dateline.to_i}|#{last.user.username}"
    self.save!
  end

  def fix_counters
    self[:threads] = Forum.find(self.id).topics_count
    self[:posts]   = Forum.find(self.id).posts_count
    self.save
    [ self[:threads], self[:posts] ]
  end

  def latest_topics(n=5, parms={})
    ids = [ self.id ]
    if parms[:include_sub]
      self.children.each do |f|
        ids << f.id
      end
    end
    id_list = "(" + ids.join(', ') + ")"
    topics = Topic.find(:all,
               :conditions => "fid IN #{id_list} AND deleted IS NULL",
               :order      => 'lastpost DESC',
               :limit      => n
    )
  end

  def self.latest_topics(id, *args)
    f = Forum.find(id)
    f.latest_topics(*args)
  end

  def self.reset_cache!
    @@tree = nil
  end

  def self.rebuild_flattened_list_seq!
    self_and_children = lambda do |f|
      fs = []
      fs << f
      f.children.each do |i|
        fs << self_and_children.call(i)
      end
      fs.flatten
    end
    forums = []
    self.find(
      :all,
      :conditions => 'fup = 0',
      :order      => 'displayorder'
    ).each do |f|
      forums << self_and_children.call(f)
    end
    seq = 0
    forums.flatten.each do |i|
      seq += 1
      i.flattened_list_seq = seq
      i.save!
    end
  end

  def self.flattened_list
    self.find(:all, :order => 'flattened_list_seq')
  end

  def self.fix_post_count!
    ftn = self.table_name
    ptn = Post.table_name
    ctn = 'tmp_forum_posts_count'
    q1  = "CREATE TEMPORARY TABLE #{ctn} (
      SELECT fid, COUNT(1) AS posts_count FROM #{ptn}
      WHERE deleted_by IS NULL
      GROUP BY fid
    )"
    q2  = "UPDATE #{ftn} f
      INNER JOIN #{ctn} c ON f.fid = c.fid
      SET f.posts = c.posts_count"
    q3  = "DROP TABLE #{ctn}"
    self.connection.execute q1
    self.connection.execute q2
    self.connection.execute q3
  end


  def move_to_sub(forum)
    raise ArgumentError unless forum.is_a? Forum
    self.fup = forum.id
    self[:type] = "sub"
    self.save
  end

end
