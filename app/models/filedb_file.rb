class FiledbFile < ActiveRecord::Base
  set_table_name       FILEDB_PREFIX + 'files'
  establish_connection FILEDB_CONN_PARAMS
  set_primary_key      'file_id'
  has_one              :filedb_filedata
  belongs_to           :filedb_category, :foreign_key => 'file_catid'
  belongs_to           :filedb_license,  :foreign_key => 'file_license'
  belongs_to           :user
  MIMETYPES = {
    'zip'  => 'application/zip',
    'pdf'  => 'application/pdf',
    'rtf'  => 'application/rtf',
    'txt'  => 'text/plain',
    'html' => 'text/html',
    'doc'  => 'application/msword',
  }
  def sync_data # {{{
    require 'net/http'
    #url  = self.file_dlurl.sub("\340", "%E0")
    #url  = self.file_dlurl.sub(" ", "%20")
    url  = URI.escape(self.file_dlurl)
    data = Net::HTTP.get(URI.parse(url))
    fd   = self.filedb_filedata
    unless (fd)
      fd = FiledbFiledata.new
    else
      return true
    end
    fd.filedb_file_id = self.id
    fd.filesize       = data.length
    fd.filename       = URI.unescape(File.basename(URI.split(url)[5]))
    fd.data           = data
    ext               = fd.filename.sub(/.*\.([^.]+)$/, "\\1").downcase
    fd.mimetype       = MIMETYPES[ext]
    fd.save
    puts "synced #{fd.filename} (file #{self.id})"
  end # }}}
  def license # {{{
    filedb_license
  end # }}}
  def category # {{{
    filedb_category
  end # }}}
  def name # {{{
    file_name
  end # }}}
  def description # {{{
    file_desc
  end # }}}
  def FiledbFile.find_all_unapproved # {{{
    FiledbFile.find(:all, 
                    :conditions => 'approved_by IS NULL',
                    :order      => 'file_time')
  end # }}}
end
