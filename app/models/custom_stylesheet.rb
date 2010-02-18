class CustomStylesheet < ActiveRecord::Base

  def self.find_by_object(obj)
    self.find(:first, :conditions => [ 'obj_class = ? AND obj_id = ?', obj.class.to_s, obj.id ])
  end

end
