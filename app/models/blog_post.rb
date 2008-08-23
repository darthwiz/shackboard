class BlogPost < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  has_and_belongs_to_many :categories

  def self.find_latest(what=:posts, n=5, opts={})
    case what
    when :posts
      posts = BlogPost.find(
        :all,
        :conditions => [ 'blog_post_id = 0' ],
        :order      => 'created_at DESC',
        :limit      => n
      )
      return posts
    when :comments
      return [] # TODO implement this
    else
      return [] # TODO implement this
    end
  end
end
