class LastVisit < ActiveRecord::Base
  belongs_to :user
  belongs_to :object, :polymorphic => true

  def self.cleanup(user, object)
    self.delete_all(:user_id => user.id, :object_type => object.class.to_s, :object_id => object.id)
  end

end
