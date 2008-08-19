class Category < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :blog_posts
  validates_length_of :name, :minimum => 1
  validates_uniqueness_of :name, :scope => [ :user_id, :owner_class, :owner_id ]
  validates_uniqueness_of :label, :scope => [ :user_id, :owner_class, :owner_id ]
  validates_format_of :label, :with => /[a-z][a-z0-9\-_]*/

  def name=(s)
    self[:name] = s.strip
  end
end
