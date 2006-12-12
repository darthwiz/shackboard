class FiledbCategory < ActiveRecord::Base
  set_table_name  FILEDB_PREFIX + 'cat'
  set_primary_key "cat_id"
  def name # {{{
    cat_name
  end # }}}
  def order # {{{
    cat_order
  end # }}}
end
