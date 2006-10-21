class FiledbCategory < ActiveRecord::Base
  set_table_name FILEDB_PREFIX + 'cat'
  establish_connection FILEDB_CONN_PARAMS
  set_primary_key "cat_id"
end
