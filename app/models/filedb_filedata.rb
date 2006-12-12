class FiledbFiledata < ActiveRecord::Base
  require 'zlib'
  set_table_name FILEDB_PREFIX + 'filedata'
  belongs_to :filedb_file
  def data # {{{
    Zlib::Inflate.inflate(read_attribute(:data))
  end # }}}
  def data=(data) # {{{
    write_attribute :data, Zlib::Deflate.deflate(data, 9)
  end # }}}
end
