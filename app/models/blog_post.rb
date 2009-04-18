class BlogPost < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  has_many :blog_comments
  has_and_belongs_to_many :categories

  def container
    self.blog
  end

  def self.find_latest(what=:posts, n=5, opts={})
    n = n.to_i > 0 ? n.to_i : 5
    case what
    when :posts
      posts = BlogPost.find_by_sql(
        "SELECT p.* FROM xmb_blog_posts p
        WHERE p.created_at = (
          SELECT MAX(created_at) FROM xmb_blog_posts p2
            WHERE user_id = p.user_id
          )
        ORDER BY p.created_at DESC
        LIMIT #{n}"
      )
      return posts
    when :comments
      return [] # TODO implement this
    else
      return [] # TODO implement this
    end
  end

  def self.count_unread_for(user)
    return 0 unless user.is_a? User
    self.sum(
      :unread_comments_count,
      :conditions => [ 'user_id = ? AND unread_comments_count > 0', user.id ]
    )
  end

end
