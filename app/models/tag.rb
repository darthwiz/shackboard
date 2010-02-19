class Tag < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
  belongs_to :user
end
