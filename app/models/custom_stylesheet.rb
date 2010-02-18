class CustomStylesheet < ActiveRecord::Base
  belongs_to :stylable, :polymorphic => true
end
