class Notification < ActiveRecord::Base
  belongs_to :actor,      :class_name  => 'User', :foreign_key => :actor_id
  belongs_to :recipient,  :class_name  => 'User', :foreign_key => :recipient_id
  belongs_to :notifiable, :polymorphic => true

  named_scope :with_recipient, lambda { |user|
    raise TypeError unless user.is_a?(User)
    { :conditions => { :recipient_id => user.id } }
  }
  named_scope :ordered_by_time_desc, :order => 'created_at DESC'

  def self.count_unread_for(user)
    self.with_recipient(user).count(:conditions => { :seen => false })
  end

end
