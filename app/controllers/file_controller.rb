class FileController < ApplicationController
  before_filter :authenticate
  def categories # {{{
    @categories = FiledbCategory.find :all, :order => 'cat_order'
  end # }}}
  def list # {{{
    ppp    = @opts[:ppp]
    start  = params[:start].to_i
    start  = 1 if (start == 0)
    offset = start - 1
    limit  = ppp
    # convert textual category ids to numeric {{{
    cid = params[:id].to_i
    if (cid <= 0)
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
    if (cid > 0)
      conds = "file_catid = #{cid}"
    else
      conds = "TRUE"
    end
    @files = FiledbFile.find :all,
                             :conditions => conds,
                             :offset     => offset,
                             :limit      => limit,
                             :order      => 'file_time DESC'
    @pageseq_opts = {
      :first      => 1,
      :last       => FiledbFile.count(:conditions => conds),
      :current    => start,
      :ipp        => ppp,
      :controller => 'file',
      :action     => 'list',
      :id         => cid
    }
  end # }}}
  def download # {{{
    f = FiledbFile.find(params[:id])
    send_data f.filedb_filedata.data, :filename => f.filedb_filedata.filename,
                                      :type     => f.filedb_filedata.mimetype
  end # }}}
end
