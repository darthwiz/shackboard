class Draft < ActiveRecord::Base
  serialize  :object
  belongs_to :user
  validates_presence_of :user_id, :timestamp, :object, :object_type
  def Draft.unsent_for(user) 
    raise TypeError unless user.is_a? User
    Draft.count(:conditions => ['user_id = ?', user.id])
  end 
end
