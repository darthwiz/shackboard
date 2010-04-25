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
  acts_as_votable

  default_scope :conditions => "#{self.table_name}.deleted_by IS NULL",
    :joins => "INNER JOIN #{User.table_name} default_u ON default_u.uid = #{self.table_name}.uid AND default_u.deleted_at IS NULL"

  named_scope :with_matching_text, lambda { |string|
    tn = self.table_name
    qs = self.quote_value(string)
    {
      :select     => "MATCH(#{tn}.message) AGAINST(#{qs} IN BOOLEAN MODE) AS relevance, #{tn}.*",
      :conditions => "MATCH(#{tn}.message) AGAINST(#{qs} IN BOOLEAN MODE) > 0",
      #:order      => "relevance DESC",
    }
  }

  named_scope :with_user, lambda { |user|
    uid = user.is_a?(User) ? user.id : nil
    ut  = User.table_name
    pt  = self.table_name
    {
      :conditions => { :uid => uid },
      :joins      => "INNER JOIN #{ut} AS wu_u ON #{pt}.uid = wu_u.uid AND wu_u.status != 'Anonymized'"
    }
  }

  named_scope :after_time, lambda { |time|
    { :conditions => "dateline >= #{time.to_i}" }
  }

  named_scope :before_time, lambda { |time|
    { :conditions => "dateline < #{time.to_i}" }
  }

  named_scope :public_only, lambda {
    ft = Forum.table_name
    pt = self.table_name
    { :joins => "INNER JOIN #{ft} AS po_f ON #{pt}.fid = po_f.fid AND po_f.private = '' AND po_f.userlist = ''" }
  }

  named_scope :including_seq, lambda {
    pt = self.table_name
    ut = User.table_name
    {
      :select => "#{pt}.*, COUNT(1) AS seq",
      :joins  => "LEFT JOIN #{pt} AS is_p2 ON is_p2.dateline <= #{pt}.dateline AND is_p2.tid = #{pt}.tid AND is_p2.deleted_by IS NULL
                  INNER JOIN #{ut} AS is_u ON is_p2.uid = is_u.uid AND is_u.deleted_at IS NULL",
      :group  => "#{pt}.pid",
    }
  }

  named_scope :including_user,       :include => :user
  named_scope :including_topic,      :include => :topic
  named_scope :ordered_by_relevance, :order   => 'relevance DESC'
  named_scope :ordered_by_time,      :order   => 'dateline'
  named_scope :ordered_by_time_desc, :order   => 'dateline DESC'

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
    self.topic.update_last_post!       # OPTIMIZE
    self.forum.update_last_post!       # OPTIMIZE
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
    begin
      User.find(self[:edituser])
    rescue
      nil
    end
  end

  def timestamp
    self[:dateline]
  end

  def timestamp=(ts)
    self[:dateline] = ts
  end

  def self.top_spammers(how_many, since_time, forum=:all)
    if forum.is_a?(Forum)
      conds = [ 'dateline >= ? AND fid = ?', since_time.to_i, forum.id ]
    elsif forum == :all
      conds = [ 'dateline >= ?', since_time.to_i ]
    end
    self.find(:all,
      :select     => "#{self.table_name}.uid, COUNT(1) AS count",
      :conditions => conds,
      :group      => :uid,
      :include    => [ :user ],
      :limit      => how_many,
      :order      => 'count DESC'
    )
  end

end
