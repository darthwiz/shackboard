class Pm < ActiveRecord::Base
  set_table_name table_name_prefix + "u2u"
  set_primary_key "u2uid"
end
