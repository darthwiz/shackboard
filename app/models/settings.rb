class Settings < ActiveRecord::Base
  set_table_name table_name_prefix + "settings"

  def self.edit_time_limit
    self.find(:first).expiredtime.to_i
  end

end
