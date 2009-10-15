class Announcement < ActiveRecord::Base
  validates_length_of :title, :minimum => 3

  def self.find_latest(n=5)
    self.find(:all, :order => 'date DESC', :limit => n)
  end

  def user
    User.find_by_username(self.poster)
  end

  def time
    Time.at(self.date)
  end

  def can_edit?(user)
    user.is_adm?
  end

end
