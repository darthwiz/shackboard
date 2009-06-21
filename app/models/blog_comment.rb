class BlogComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog_post
  default_scope :joins => "INNER JOIN #{User.table_name} u ON u.uid = #{self.table_name}.user_id AND u.deleted_at IS NULL AND u.status != 'Anonymized'"
  named_scope :by_time_asc, :order => :created_at

  def container
    self.blog_post
  end

  def blog
    self.blog_post.blog
  end

end
