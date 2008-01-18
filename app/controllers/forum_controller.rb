class ForumController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :update_online,
    :set_stylesheet, :only => [ :css ]
  def index 
    @forums = Forum.find(:all, :conditions => 'fup = 0',
                               :order      => 'displayorder')
  end 
  def view 
    tpp    = ((@opts[:tpp] - 1) / @topic_block_size + 1) * @topic_block_size
    start  = params[:start].to_i
    start  = 0 if (start <= 0)
    rstart = (start/tpp)*tpp
    rend   = rstart + tpp - 1
    @range = rstart..rend
    # convert textual forum ids to numeric 
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
    
    # try to get the requested forum or fail nicely 
    begin
      @forum = Forum.find(fid)
    rescue
      render :partial => "not_found" and return
    end
    
    # use the user's preferred engine 
    if @preferred_engine == 1
      redirect_to @legacy_forum_uri + "/forumdisplay.php?fid=#{@forum.id}" \
        and return
    end
    
    unless @forum.acl.can_read?(@user)
      render :partial => "not_authorized" and return
    end
    conds          = ["fid = ?", fid]
    @page_seq_opts = { :last       => @forum.topics_count_cached,
                       :ipp        => tpp,
                       :current    => start + 1,
                       :id         => fid }
    @location      = [ 'Forum', @forum ]
  end 
  def tree 
    @tree = Forum.tree
  end 
  def css 
    headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name             = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end 
end
