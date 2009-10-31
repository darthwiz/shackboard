class Ban < ActiveRecord::Base
  belongs_to :user
  belongs_to :moderator, :class_name => 'User'
  belongs_to :forum

  named_scope :active_at, lambda { |time|
    raise TypeError unless time.is_a?(Time)
    { :conditions => [ 'created_at <= ? AND (expires_at >= ? OR expires_at IS NULL)', time, time ] }
  }

  named_scope :with_forum, lambda { |forum|
    raise TypeError unless forum.is_a?(Forum)
    { :conditions => { :forum_id => forum.id } }
  }

  named_scope :with_forums, lambda { |forums|
    raise TypeError unless forums.is_a?(Array)
    forums.each { |f| raise TypeError unless f.is_a?(Forum) }
    { :conditions => [ 'forum_id IN (?)', forums.collect(&:id).join(', ') ] }
  }

  named_scope :with_user, lambda { |user|
    raise TypeError unless user.is_a?(User)
    { :conditions => { :user_id => user.id } }
  }

  named_scope :with_moderator, lambda { |moderator|
    raise TypeError unless moderator.is_a?(User)
    { :conditions => { :moderator_id => moderator.id } }
  }

  def can_edit?(user)
    return false unless user.is_a?(User)
    return false if user == self.user
    return true if user.is_supermod?
    return true if user == self.moderator
    return true if self.forum.can_moderate?(user)
    false
  end

  def can_delete?(user)
    self.can_edit?(user)
  end

end
