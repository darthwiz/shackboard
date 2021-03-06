class FileController < ApplicationController
  before_filter :init
  skip_before_filter :load_defaults, :authenticate, :update_online,
    :set_stylesheet, :only => [ :css ]
  layout 'file_area'

  def categories
    @numfiles   = {}
    @categories = FiledbCategory.find :all, :order => 'cat_order'
    @categories.each { |c|
      @numfiles[c.id] = FiledbFile.count(
        :conditions => ['file_catid = ? AND approved_by IS NOT NULL', c.id] )
    }
    @location = @categories
  end

  def list
    ppp    = @opts[:ppp]
    start  = params[:start].to_i
    order  = params[:order].to_sym if params[:order]
    start  = 1 if (start == 0)
    offset = start - 1
    limit  = ppp
    # convert textual category ids to numeric
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

    if (cid.to_i > 0)
      conds = "file_catid = #{cid}"
    end
    @files = FiledbFile.find :all,
                             :conditions => conds,
                             :offset     => offset,
                             :limit      => limit,
                             :order      => order_clause(order)
    @page_seq_opts = {
      :last       => FiledbFile.count(:conditions => conds),
      :current    => start,
      :ipp        => ppp,
      :get_parms  => [:order]
    }
    @location = FiledbCategory.find(cid)
  end

  def download
    confirmed = params[:license_confirmed] || is_adm?
    id        = params[:id]
    @file     = FiledbFile.find(id, :with_unapproved => is_adm?)
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
      @location = @file
      render :action => 'confirm_license', :id => id
    end
  end

  def upload
    @categories = FiledbCategory.find(:all, :order => 'cat_order')
    if is_authenticated?
      @location = FiledbFile.new
    else
      session[:intended_action] = { :controller => controller_name,
                                    :action     => action_name }
      render :action => 'need_auth'
    end
  end

  def index
    redirect_to :action => 'categories'
  end

  def create
    @new_file = FiledbFile.new(
      :user_id       => session[:userid],
      :file_name     => params[:file][:name],
      :file_creator  => params[:file][:author],
      :file_desc     => params[:file][:description],
      :file_catid    => params[:file][:category],
      :file_license  => params[:file][:license],
      :file_posticon => params[:file][:icon],
      :file_time     => Time.now.to_i,
      :file_dls      => 0
    )
    @new_file.save
    @new_file_data = FiledbFiledata.new(
      :filename       => params[:file][:data].original_filename,
      :data           => params[:file][:data].read,
      :mimetype       => params[:file][:data].content_type.strip,
      :filesize       => params[:file][:data].length,
      :filedb_file_id => @new_file.id
    )
    @new_file_data.save
    redirect_to :action => :index
  end

  def review
    redirect_to :action => :categories unless is_adm?
    @categories = FiledbCategory.find :all, :order => 'cat_order'
    @unapproved = FiledbFile.find(:all, :only_unapproved => true)
  end

  def approve
    render :nothing unless is_adm?
    @categories   = FiledbCategory.find :all, :order => 'cat_order'
    id            = params[:id]
    f             = FiledbFile.find(id, :with_unapproved => true)
    param_hash    = {}
    # this is a trick to transform from params[:keys][id] to just params[:keys]
    # which is nicer as we don't need to duplicate all the assignments already
    # present in the model -- just pass everything along, the model will take
    # care of it.
    params.each_pair do |key, value|
      param_hash[key.to_sym] = value[id] if value.is_a? Hash
    end
    f.approve(@user, param_hash)
    expire_fragment(:controller => 'file', :action => 'latest')
  end

  def unapprove
    render :nothing unless is_adm?
    @categories = FiledbCategory.find :all, :order => 'cat_order'
    FiledbFile.unapprove(params[:id].to_i)
    expire_fragment(:controller => 'file', :action => 'latest')
  end

  def delete
    render :nothing unless is_adm?
    id = params[:id].to_i
    @file = FiledbFile.find(id, :with_unapproved => true)
    @file.destroy
  end

  def show_icon
    render :partial => 'icon', :locals => { :icon => params[:icon] }
  end

  def search
    words = params[:file].to_s.scan_words
    start = params[:start].to_i
    order = params[:order].to_sym if params[:order]
    start = 1 if start < 1
    if words.empty?
      render :action => 'search'
    else
      @categories    = FiledbCategory.find :all, :order => 'cat_order'
      @results_count = FiledbFile.count_by_words(
        words,
        :with_unapproved => false # is_adm?
      )
      @results       = FiledbFile.find_all_by_words(
        words,
        :with_unapproved => false, # is_adm?,
        :offset          => start - 1,
        :limit           => @opts[:ppp],
        :order           => order_clause(order)
      )
      @location = @results
      render :action => 'results'
    end
  end

  def css
    headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name             = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end

  private

  def is_adm?(user=@user)
    begin
      Group.include?(['Group', FILEDB_ADM_GROUP], user)
    rescue
      return false
    end
  end

  def order_clause(order)
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
  end

  def init
    @page_title = "Area Materiali studentibicocca.it"
  end

end
