class TopicController < ApplicationController
  def new # {{{
    @forum = Forum.find(params[:id])
    unless @forum.can_post?(@user)
      redirect_to :action => 'view', :id => @forum.id and return
    end
    draft_id        = params[:draft].to_i
    @post           = Post.new
    @post[:subject] = ''
    @post.forum     = @forum
    if draft_id > 0
      conds  = [ 'id = ? AND object_type = ? AND user_id = ?', draft_id,
        'Post', @user.id ]
      @draft = Draft.find(:first, :conditions => conds) || Draft.new
      @post  = @draft.object if @draft.object
    else
      @draft           = Draft.new
      @draft.user      = @user
      @draft.timestamp = Time.now.to_i
      @draft.object    = @post
      @draft.save
    end
    @location = [ 'Forum', @forum, :new ]
    render '/post/new'
  end # }}}
  def view # {{{
    ppp    = ((@opts[:ppp] - 1) / @post_block_size + 1) * @post_block_size
    start  = params[:start].to_i - 1
    start  = 0 if (start <= 0)
    rstart = (start/ppp)*ppp
    rend   = rstart + ppp - 1
    @range = rstart..rend
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
    # redirect if the topic has moved {{{
    if (@topic.actual && @topic.id != @topic.actual.id)
      redirect_to :action => 'view', :id => @topic.actual.id and return
      # FIXME manage start and anchors too
    end
    # }}}
    # don't show 'start=1' if this is the first page (URL aesthetics!) {{{
    redirect_to :action => 'view', :id => @topic.id and return \
      if params[:start].to_i == 1
    # }}}
    # avoid indexing permalinks as different pages {{{
    if (start != rstart)
      redirect_to :action => 'view', :id => @topic.id and return if start < ppp
      redirect_to :action => 'view', :id => @topic.id, :start => rstart + 1 \
        and return
    end
    # }}}
    # use the user's preferred engine {{{
    if @preferred_engine == 1
      redirect_to @legacy_forum_uri + "/viewthread.php?tid=#{@topic.id}" \
        and return
    end
    # }}}
    # }}}
    # check access control once we have found the topic {{{
    unless @topic.can_read?(@user)
      render :partial => "not_authorized" and return
    end
    # }}}
    if params[:page] == 'last'
      # XXX refactor here
      start  = @topic.total_posts
      rstart = (start/ppp)*ppp
      rend   = rstart + ppp - 1
      @range = rstart..rend
    end
    @page_seq_opts = { :last        => @topic.replies + 1,
                       :ipp         => ppp,
                       :current     => start + 1,
                       :id          => tid,
                       :extra_links => [ :first, :forward, :back, :last ] }
    @location      = [ 'Topic', @topic ]
    @topic.save
  end # }}}
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
end
