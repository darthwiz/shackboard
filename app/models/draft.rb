class Draft < ActiveRecord::Base
  serialize  :object
  belongs_to :user
  validates_presence_of :user_id, :timestamp, :object, :object_type
  def save # {{{
    self.object_type = self.object.class.to_s
    super
  end # }}}
end
