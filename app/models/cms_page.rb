class CmsPage < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'created_by'
  validates_format_of :slug, :with => /\A[a-z0-9-]+\Z/
  validates_uniqueness_of :slug
end
