class BlogComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog_post

  def container
    self.blog_post
  end

  def blog
    self.blog_post.blog
  end

end
