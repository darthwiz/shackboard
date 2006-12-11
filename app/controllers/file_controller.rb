class FileController < ApplicationController
  before_filter :authenticate
  def categories # {{{
    @numfiles   = {}
    @categories = FiledbCategory.find :all, :order => 'cat_order'
    @categories.each { |c|
      @numfiles[c.id] = FiledbFile.count(
        :conditions => ['file_catid = ? AND approved_by IS NOT NULL', c.id] )
    }
  end # }}}
  def list # {{{
    ppp    = @opts[:ppp]
    start  = params[:start].to_i
    order  = params[:order].to_sym if params[:order]
    start  = 1 if (start == 0)
    offset = start - 1
    limit  = ppp
    # convert textual category ids to numeric {{{
    cid = params[:id]
    if (cid.nil?)
      conds = "TRUE"
    elsif (cid.to_i == 0)
      cat = FiledbCategory.find(
        :first,
        :conditions => ['cat_name LIKE ?', params[:id].to_s + '%'],
        :order      => 'cat_order'
      )
      if (cat.is_a? FiledbCategory)
        cid = cat.id
      end
    end
    # }}}
    if (cid.to_i > 0)
      conds = "file_catid = #{cid} AND approved_by IS NOT NULL"
    end
    @files = FiledbFile.find :all,
                             :conditions => conds,
                             :offset     => offset,
                             :limit      => limit,
                             :order      => order_clause(order)
    @pageseq_opts = {
      :last       => FiledbFile.count(:conditions => conds),
      :current    => start,
      :ipp        => ppp,
      :get_parms  => [:order]
    }
  end # }}}
  def download # {{{
    confirmed = params[:license_confirmed] || is_adm?
    id        = params[:id]
    @file     = FiledbFile.find(id)
    if confirmed
      send_data @file.filedb_filedata.data,
        :filename => @file.filedb_filedata.filename,
        :type     => @file.filedb_filedata.mimetype
      if (@file.file_dls > 0)
        @file.file_dls += 1
        @file.save
      else
        @file.file_dls = 1
        @file.save
      end
    else
      render :action => 'confirm_license', :id => id
    end
  end # }}}
  def upload # {{{
    @categories = FiledbCategory.find(:all, :order => 'cat_order')
  end # }}}
  def index # {{{
    redirect_to :action => 'categories'
  end # }}}
  def create # {{{
    @new_file = FiledbFile.new { |f|
      f.user_id       = session[:userid]
      f.file_name     = params[:file][:name]
      f.file_desc     = params[:file][:description]
      f.file_catid    = params[:file][:category]
      f.file_license  = params[:file][:license]
      f.file_posticon = params[:file][:icon]
      f.file_time     = Time.now.to_i
      f.file_dls      = 0
    }
    @new_file.save
    @new_file_data = FiledbFiledata.new { |fd|
      fd.filename       = params[:file][:data].original_filename
      fd.data           = params[:file][:data].read
      fd.mimetype       = params[:file][:data].content_type.strip
      fd.filedb_file_id = @new_file.id
    }
    @new_file_data.save
    redirect_to :action => :index
  end # }}}
  def review # {{{
    redirect_to :action => :categories unless is_adm?
    @categories = FiledbCategory.find :all, :order => 'cat_order'
    @unapproved = FiledbFile.find_all_unapproved
  end # }}}
  def approve # {{{
    render :nothing unless is_adm?
    @categories   = FiledbCategory.find :all, :order => 'cat_order'
    id            = params[:id]
    f             = FiledbFile.find(id)
    f.approve(@user,
      :name        => params[:name][id.to_s],
      :description => params[:description][id.to_s],
      :category    => params[:category][id.to_s].to_i,
      :icon        => params[:icon][id.to_s]
    )
  end # }}}
  def unapprove # {{{
    render :nothing unless is_adm?
    @categories = FiledbCategory.find :all, :order => 'cat_order'
    FiledbFile.unapprove(params[:id].to_i)
  end # }}}
  def delete # {{{
    render :nothing unless is_adm?
    id = params[:id].to_i
    @file = FiledbFile.destroy(id)
  end # }}}
  def show_icon # {{{
    render :partial => 'icon', :locals => { :icon => params[:icon] }
  end # }}}
  def search # {{{
    words = params[:file].to_s.scan_words
    start = params[:start].to_i
    order = params[:order].to_sym if params[:order]
    start = 1 if start < 1
    if words.empty?
      render :action => 'search'
    else
      @results_count = FiledbFile.count_by_name_words(words)
      @results       = FiledbFile.find_by_name_words(
        words,
        :offset => start - 1,
        :limit  => @opts[:ppp],
        :order  => order_clause(order)
      )
      render :action => 'results'
    end
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
  private
  def is_adm?(user=@user) # {{{
    Group.include?(FILEDB_ADM_GROUP, user)
  end # }}}
  def order_clause(order) # {{{
    case order
    when :name
      order_clause = 'file_name'
    when :description
      order_clause = 'file_desc'
    when :author
      order_clause = 'file_creator, file_time DESC'
    when :downloads
      order_clause = 'file_dls DESC'
    when :time
      order_clause = 'file_time DESC'
    else
      order_clause = 'file_name'
    end
  end # }}}
end
