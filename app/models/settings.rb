class Settings < ActiveRecord::Base
  set_table_name table_name_prefix + "settings"
end
