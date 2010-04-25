class BlogPost < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  acts_as_simply_taggable
  acts_as_commentable
  default_scope :joins => "INNER JOIN #{User.table_name} u ON u.uid = #{self.table_name}.user_id AND u.deleted_at IS NULL AND u.status != 'Anonymized'"
  named_scope :by_created_at_asc, :order => :created_at
  named_scope :by_created_at_desc, :order => 'created_at DESC'

  def container
    self.blog
  end

  def can_comment?(user)
    user.is_a?(User)
  end

  def can_tag?(user)
    user == self.user
  end

  def can_edit_comments?(user)
    user == self.user
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
    return 0 # FIXME dropped for now...
  end

end
