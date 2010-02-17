class BlogPost < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  has_many :blog_comments
  has_and_belongs_to_many :categories
  default_scope :joins => "INNER JOIN #{User.table_name} u ON u.uid = #{self.table_name}.user_id AND u.deleted_at IS NULL AND u.status != 'Anonymized'"
  named_scope :by_time_asc, :order => :created_at

  def container
    self.blog
  end

  def self.find_latest(what=:posts, n=5, opts={})
    n     = n.to_i > 0 ? n.to_i : 5
    now   = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    posts = self.find_by_sql("
      SELECT p.* FROM xmb_blog_posts p
      INNER JOIN #{User.table_name} u 
        ON (p.user_id = u.uid AND u.deleted_at IS NULL AND u.status != 'Anonymized')
      LEFT JOIN #{Ban.table_name} b
        ON b.user_id = p.user_id AND b.created_at <= '#{now}' AND '#{now}' <= b.expires_at
      WHERE p.created_at = (
        SELECT MAX(created_at) FROM xmb_blog_posts p2
          WHERE user_id = p.user_id
        )
        AND b.moderator_id IS NULL
      GROUP BY p.id
      ORDER BY p.created_at DESC
      LIMIT #{n}"
    )
  end

  def self.count_unread_for(user)
    return 0 unless user.is_a? User
    self.sum(
      :unread_comments_count,
      :conditions => [ 'user_id = ? AND unread_comments_count > 0', user.id ]
    )
  end

end
