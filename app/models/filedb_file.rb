class FiledbFile < ActiveRecord::Base
  require 'iso_helper.rb'
  include ActiveRecord::IsoHelper
  set_table_name       FILEDB_PREFIX + 'files'
  establish_connection FILEDB_CONN_PARAMS
  set_primary_key      'file_id'
  has_one              :filedb_filedata, :dependent   => :destroy
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
    fd   = FiledbFiledata.find_by_sql("select id
      from portal.materiali_filedata
      where id = #{self.id}")
    return true unless fd.empty?
    fd   = FiledbFiledata.new
    pfx  = 'http://www.studentibicocca.it/portale/materiali/'
    url  = URI.escape(self.file_dlurl)
    url  = pfx + url if url !~ /^http:/
    puts "#{self.id} GET #{url}"
    begin
      data = Net::HTTP.get(URI.parse(url))
      fd.id             = self.id
      fd.filedb_file_id = self.id
      fd.filesize       = data.length
      fd.filename       = URI.unescape(File.basename(URI.split(url)[5]))
      fd.data           = data
      ext               = fd.filename.sub(/.*\.([^.]+)$/, "\\1").downcase
      fd.mimetype       = MIMETYPES[ext]
      if fd.save 
        puts "#{self.id} SAVED #{fd.filename}"
      else
        puts "#{self.id} FAILED #{fd.filename}"
      end
    rescue URI::InvalidURIError
      puts "#{self.id} FAILED (invalid URI)"
    end
    nil
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
  def approve(user, opts={}) # {{{
    self.approved_by   = user.id
    self.file_name     = opts[:name]        if opts[:name]
    self.file_catid    = opts[:category]    if opts[:category]
    self.file_desc     = opts[:description] if opts[:description]
    self.file_posticon = opts[:icon]        if opts[:icon]
    self.save
  end # }}}
  def unapprove # {{{
    self.approved_by = nil
    self.save
  end # }}}
  def FiledbFile.find_all_unapproved # {{{
    FiledbFile.find(:all, 
                    :conditions => 'approved_by IS NULL',
                    :order      => 'file_time')
  end # }}}
  def FiledbFile.unapprove(id) # {{{
    f = FiledbFile.find(id)
    f.unapprove
  end # }}}
end
