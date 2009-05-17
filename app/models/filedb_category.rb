class FiledbCategory < ActiveRecord::Base
  set_table_name  FILEDB_PREFIX + 'cat'
  set_primary_key "cat_id"
  alias_attribute :name, :cat_name
  alias_attribute :order, :cat_order

end
