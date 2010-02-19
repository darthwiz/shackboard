class Geomark < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :lat, :lng, :name, :user_id
end
