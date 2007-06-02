class TopicController < ApplicationController
  def view # {{{
    ppp   = @opts[:ppp]
    start = params[:start].to_i - 1
    start = 0 if (start <= 0)
    # convert textual topic ids to numeric {{{
    tid = params[:id].to_i
    if (tid <= 0) then
      topic = Topic.find(
        :first,
        :conditions => ["subject LIKE ?", params[:id].to_s + "%"],
        :order => 'lastpost DESC'
      )
      if (topic.is_a? Topic) then
        tid = topic.id
      end
    end
    # }}}
    # try to get the requested topic or fail nicely {{{
    begin
      @topic = Topic.find(tid)
      fid    = @topic.fid
    rescue
      render :partial => "not_found" and return
    end
    # }}}
    # redirect if needed {{{
    if (@topic.actual && @topic.id != @topic.actual.id)
      redirect_to :action => 'view', :id => @topic.actual.id
      # FIXME manage start and anchors too
    end
    # }}}
    # check access control once we have found the topic {{{
    unless @topic.can_read?(@user)
      render :partial => "not_authorized" and return
    end
    # }}}
    start  = @topic.total_posts if params[:page] == 'last'
    rstart = (start/ppp)*ppp
    rend   = rstart + ppp - 1
    @range = rstart..rend
    @page_seq_opts = { :last        => @topic.replies + 1,
                       :ipp         => ppp,
                       :current     => start + 1,
                       :id          => tid,
                       :extra_links => [ :first, :forward, :back, :last ] }
    @location      = [ 'Topic', @topic ]
    @topic.views  += 1
    @topic.save
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
end
