class ForumController < ApplicationController
  before_filter :forum_cache
  def index # {{{
    @forums = Forum.find(:all, :conditions => 'fup = 0',
                               :order      => 'displayorder')
  end # }}}
  def view # {{{
    tpp   = @opts[:tpp]
    start = params[:start].to_i
    start = 1 if (start < tpp + 1)
    # convert textual forum ids to numeric {{{
    fid = params[:id].to_i
    if (fid <= 0) then
      forum = Forum.find(
        :first,
        :conditions => ['name LIKE ?', '%' + params[:id].to_s + '%'],
        :order => 'posts DESC'
      )
      if (forum.is_a? Forum) then
        fid = forum.id
      end
    end
    # }}}
    # try to get the requested forum or fail nicely {{{
    begin
      @forum = Forum.find(fid)
    rescue
      render :partial => "not_found" and return
    end
    # }}}
    unless @forum.acl.can_read?(@user)
      render :partial => "not_authorized" and return
    end
    offset         = ((start - 1)/tpp)*tpp
    limit          = tpp
    conds          = ["fid = ?", fid]
    @topics        = @forum.topics(offset...(offset + limit))
    @page_seq_opts = { :last       => @forum.topics_count_cached,
                       :ipp        => tpp,
                       :current    => start,
                       :id         => fid }
    @location      = [ 'Forum', @forum ]
  end # }}}
  def tree # {{{
    @tree = Forum.tree
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
end
