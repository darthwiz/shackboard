class FiledbFile < ActiveRecord::Base
  require 'iso_helper.rb'
  include ActiveRecord::IsoHelper
  set_table_name  FILEDB_PREFIX + 'files'
  set_primary_key 'file_id'
  has_one         :filedb_filedata, :dependent   => :destroy
  belongs_to      :filedb_category, :foreign_key => 'file_catid'
  belongs_to      :filedb_license,  :foreign_key => 'file_license'
  belongs_to      :user
  validates_presence_of     :file_name
  validates_numericality_of :file_catid
  MIMETYPES = { # {{{
    'zip'  => 'application/zip',
    'pdf'  => 'application/pdf',
    'rtf'  => 'application/rtf',
    'txt'  => 'text/plain',
    'html' => 'text/html',
    'doc'  => 'application/msword',
  } # }}}
  def sync_data # {{{
    require 'net/http'
    fd   = self.metadata
    return true unless fd.nil?
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
    self.file_name     = opts[:name]          if opts[:name]
    self.file_catid    = opts[:category].to_i if opts[:category]
    self.file_desc     = opts[:description]   if opts[:description]
    self.file_posticon = opts[:icon]          if opts[:icon]
    self.file_creator  = opts[:author]        if opts[:author]
    if opts[:filename]
      FiledbFiledata.update(self.metadata.id, { :filename => opts[:filename] } )
    end
    self.save
  end # }}}
  def unapprove # {{{
    self.approved_by = nil
    self.save
  end # }}}
  def approved? # {{{
    return true unless self.approved_by.nil?
    false
  end # }}}
  def metadata # {{{
    attrs = FiledbFiledata.new.attribute_names
    attrs.delete("data")
    attr_list = "id"
    attrs.each { |i| attr_list += ", #{i}" }
    FiledbFiledata.find_by_filedb_file_id(
      self.id,
      :select   => attr_list,
      :readonly => true
    )
  end # }}}
  def FiledbFile.count_by_words(words, opts={}) # {{{
    conds = FiledbFile.new.send(:words_to_conds, words)
    conds << " AND approved_by IS NOT NULL" unless opts[:with_unapproved]
    conds.sub!(/^ AND /, '')
    FiledbFile.count(:conditions => conds)
  end # }}}
  def FiledbFile.find_all_by_words(words, opts={}) # {{{
    conds = FiledbFile.new.send(:words_to_conds, words)
    opts[:conditions] = conds
    FiledbFile.find(:all, opts)
  end # }}}
  def FiledbFile.unapprove(id) # {{{
    f = FiledbFile.find(id, :with_unapproved => true) # XXX wtf?
    f.unapprove
  end # }}}
  def FiledbFile.count_approved # {{{
    FiledbFile.count(:conditions => 'approved_by IS NOT NULL')
  end # }}}
  def FiledbFile.count_unapproved # {{{
    FiledbFile.count(:conditions => 'approved_by IS NULL')
  end # }}}
  def FiledbFile.latest(n=5) # {{{
    FiledbFile.find(
      :all,
      :order => 'file_time DESC',
      :limit => n
    )
  end # }}}
  def FiledbFile.find(*args) # {{{
    opts = extract_options_from_args!(args)
    opts[:conditions] = '' unless opts[:conditions]
    unless (opts[:with_unapproved] || opts[:only_unapproved])
      opts[:conditions] += ' AND approved_by IS NOT NULL'
    end
    if (opts[:only_unapproved])
      opts[:conditions] += ' AND approved_by IS NULL'
    end
    opts[:conditions].sub!(/^ AND /, '')
    opts[:conditions] = nil if opts[:conditions].strip.empty?
    opts.delete(:with_unapproved)
    opts.delete(:only_unapproved)
    validate_find_options(opts)
    set_readonly_option!(opts)
    case args.first
      when :first then find_initial(opts)
      when :all   then find_every(opts)
      else             find_from_ids(args, opts)
    end
  end # }}}
  private
  def words_to_conds(words) # {{{
    conds = ""
    words.each do |i|
      word   = ActiveRecord::Base.send(:sanitize_sql, i)
      conds << " AND (file_name LIKE '%#{word}%'"
      conds << " OR file_creator LIKE '%#{word}%'"
      conds << " OR file_desc LIKE '%#{word}%')"
    end
    conds.sub(/^ AND /, '')
  end # }}}
end
