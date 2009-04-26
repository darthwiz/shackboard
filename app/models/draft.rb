class Draft < ActiveRecord::Base
  serialize  :object
  belongs_to :user
  validates_presence_of :user_id, :object, :object_type

  def object
    # FIXME it would be nice to make this hack work here instead of outside
    Module.const_get(self.object_type.classify).new unless self.object_type.nil?
    self[:object][0]
  end

  def object=(obj)
    self[:object] = [ obj ]
  end

  def self.find_paged_for(user, offset=0, limit=25)
    return [] unless user.is_a? User
    self.find(
      :all,
      :conditions => [ 'user_id = ?', user.id ],
      :offset     => offset,
      :limit      => limit,
      :order      => 'updated_at DESC'
    )
  end

  def self.secure_find(id, user)
    draft = self.find(id)
    uid   = user.is_a?(User) ? user.id : nil
    raise ::UnauthorizedError unless draft.user_id == uid
    draft
  end

  def self.unsent_for(user) 
    raise TypeError unless user.is_a? User
    Draft.count(:conditions => ['user_id = ?', user.id])
  end 

end
