class Draft < ActiveRecord::Base
  serialize  :object
  belongs_to :user
  validates_presence_of :user_id, :timestamp, :object, :object_type
  def save # {{{
    self.object_type = self.object.class.to_s
    case self.object_type
    when 'Post'
      raise unless self.object.forum.is_a? Forum # XXX rough validity check
    end
    super
  end # }}}
  def Draft.unsent_for(user) # {{{
    raise TypeError unless user.is_a? User
    Draft.count(:conditions => ['user_id = ?', user.id])
  end # }}}
end
