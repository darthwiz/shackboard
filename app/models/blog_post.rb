class BlogPost < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  belongs_to :blog_post
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

  def self.count_unread_for(user)
    return 0 unless user.is_a? User
    self.sum(
      :unread_comments_count,
      :conditions => [ 'user_id = ? AND blog_post_id = 0 AND unread_comments_count > 0', user.id ]
    )
  end

end
