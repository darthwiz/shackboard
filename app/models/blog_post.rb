class BlogPost < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  has_and_belongs_to_many :categories
end
