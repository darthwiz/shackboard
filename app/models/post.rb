class Post < ActiveRecord::Base
  require 'magic_fixes.rb'
  include ActiveRecord::MagicFixes
  set_primary_key "pid"
  belongs_to :topic, :foreign_key => 'tid', :counter_cache => :replies
  belongs_to :forum, :foreign_key => 'fid', :counter_cache => :posts
  belongs_to :user,  :foreign_key => 'uid', :counter_cache => :postnum
  #belongs_to :post,  :foreign_key => 'reply_to_pid'
  attr_accessor :seq, :subject, :cached_can_edit, :cached_can_read,
    :cached_has_blog, :cached_smileys, :cached_online, :cached_user,
    :cached_edited_by
  alias_attribute :created_at, :dateline
  default_scope :conditions => { :deleted_by => nil }
  
  def text
    self.message
  end

  def text=(s)
    self.message = s
  end

  def container
    self.topic
  end

  def user_id
    self.uid
  end

  def topic_id
    self.tid
  end

  def topic_id=(tid)
    self.tid = tid
  end

  def actual
    return self unless self.new_record?
    self.topic
  end

  def find_seq
    self.class.count(:conditions => [ 'tid = ? AND dateline <= ? AND deleted_by IS NULL', self.topic_id, self.dateline ])
  end

  def self.secure_find(id, user=nil)
    post = self.find(id)
    raise ::UnauthorizedError unless post.can_read?(user)
    post
  end

  def self.secure_find_for_edit(id, user)
    post = self.find(id)
    raise ::UnauthorizedError unless post.can_edit?(user)
    post
  end

  def self.count_replies_to_user(user, since=1.week.ago)
    self.count(:conditions => [ 'reply_to_uid = ? AND dateline >= ?', user, since.to_i ])
  end

  def self.find_replies_to_user(user, since=1.week.ago, limit=50)
    return [] unless user.is_a? User
    self.find(
      :all,
      :conditions => [ 'reply_to_uid = ? AND dateline >= ?', user.id, since.to_i ],
      :include    => [ :user ],
      :order      => 'dateline DESC',
      :limit      => limit
    )
  end

  def delete(by_whom)
    self.deleted_by = by_whom.id
    self.deleted_on = Time.now.to_i
    self.save!
    self.topic.update_last_post!
    self.forum.update_last_post!
    self.user.decrement!(:postnum)     # FIXME this doesn't appear to work
    self.topic.decrement!(:replies)
    self.forum.decrement(:posts).save! # NOTE this syntax is needed because the
                                       # 'posts' attribute clashes with the
                                       # 'posts' method
  end

  def can_edit?(user=nil)
    # try to return the "pushed" value first and do the calculations and
    # queries only if it isn't there
    return @can_edit unless @can_edit.nil?
    return false unless user.is_a? User
    return true if (self.uid == user.id) && (Time.now.to_i - self.dateline < Settings.edit_time_limit)
    return true if self.topic.can_moderate?(user)
    return false
  end

  def can_read?(user=nil)
    self.container.can_read?(user)
  end

  def can_post?(user=nil)
    self.container.can_post?(user)
  end

  def before_save
    self.text = Sanitizer.sanitize_bb(self.text)
  end

  def created_at
    Time.at(self.dateline)
  end

  def updated_at
    Time.at(self.editdate)
  end

  def updated_by
    return nil unless self[:edituser] > 0
    User.find(self[:edituser])
  end

  def timestamp
    self[:dateline]
  end

  def timestamp=(ts)
    self[:dateline] = ts
  end

end
