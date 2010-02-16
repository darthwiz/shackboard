class Tag < ActiveRecord::Base

  def self.find_by_object(obj)
    self.find(:all, :conditions => [ 'obj_class = ? AND obj_id = ?', obj.class.to_s, obj.id ])
  end

end
