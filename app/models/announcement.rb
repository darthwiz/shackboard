class Announcement < ActiveRecord::Base
  validates_length_of :title, :minimum => 3
  acts_as_simply_taggable

  named_scope :not_expired, lambda {
    { :conditions => [ 'expires_at > ?', Time.now ] }
  }

  def self.find_latest(n=5)
    self.not_expired.find(:all, :order => 'date DESC', :limit => n)
  end

  def user
    User.find_by_username(self.poster)
  end

  def time
    Time.at(self.date)
  end

  def can_edit?(user)
    user.is_supermod?
  end

  def self.can_create?(user)
    user.is_supermod?
  end

end
