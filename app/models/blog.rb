class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :blog_posts, :dependent => :destroy
  validates_length_of :name, :minimum => 1
  validates_uniqueness_of :name, :scope => :user_id
  validates_format_of :label, :with => /[a-z][a-z0-9\-_]*/

  def categories
    Category.find(
      :all,
      :conditions => [ 'owner_class = ? AND owner_id = ?', 'Blog', self.id ],
      :order      => :name
    )
  end

end
