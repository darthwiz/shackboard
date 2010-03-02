class Vote < ActiveRecord::Base
  belongs_to :votable, :polymorphic => true
  belongs_to :user

  named_scope :by_user, lambda { |user|
    raise TypeError unless user.is_a?(User)
    { :conditions => { :user_id => user.id } }
  }

end
