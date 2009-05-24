class CmsPage < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :updater, :class_name => 'User', :foreign_key => :updated_by
  validates_length_of :title, :minimum => 1
  validates_format_of :slug, :with => /\A[a-z0-9-]+\Z/
  validates_uniqueness_of :slug
  default_scope :conditions => { :deleted_by => nil }

  def can_edit?(user)
    Group.find_by_name('portale_w').include?(user)
  end

  def self.can_edit?(user)
    Group.find_by_name('portale_w').include?(user)
  end

end
