class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  default_scope :joins => "INNER JOIN #{User.table_name} u ON u.uid = #{self.table_name}.user_id AND u.deleted_at IS NULL AND u.status != 'Anonymized'"
  named_scope :by_created_at_asc, { :order => 'created_at' }
  named_scope :including_user, :include => [ :user ]

  def can_edit?(user)
    return true if user == self.user
    obj = self.commentable
    obj.respond_to?(:can_edit_comments?) && obj.can_edit_comments?(user)
  end

end
