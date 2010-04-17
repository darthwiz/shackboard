class SetPlausibleCreationTimesToTags < ActiveRecord::Migration

  def self.up
    time_start = Time.parse('Fri Feb 19 12:46:14 2010 +0000')
    time_end   = Time.now
    tags       = Tag.find(:all, :conditions => { :created_at => nil }, :order => 'id')
    tags_count = tags.size
    interval   = time_end - time_start
    time       = time_start
    tags.each do |t|
      t.created_at  = time
      time         += interval / tags_count
      t.save
    end
  end

  def self.down
  end

end
