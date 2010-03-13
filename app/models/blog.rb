class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :posts, :class_name => 'BlogPost', :dependent => :destroy
  validates_length_of :name, :minimum => 1
  validates_uniqueness_of :name, :scope => :user_id
  validates_format_of :slug, :with => /[a-z][a-z0-9\-]*/
  default_scope :joins => :user, :conditions => "#{User.table_name}.deleted_at IS NULL"
end
