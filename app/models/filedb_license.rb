class FiledbLicense < ActiveRecord::Base
  set_table_name FILEDB_PREFIX + 'license'
  establish_connection FILEDB_CONN_PARAMS
  set_primary_key "license_id"
  def name # {{{
    license_name
  end # }}}
  def text # {{{
    license_text
  end # }}}
end
