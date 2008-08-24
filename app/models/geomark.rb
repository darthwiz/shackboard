class Geomark < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :categories
  validates_presence_of :lat, :lng, :name, :user_id
end
