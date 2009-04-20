class TopicsController < ApplicationController
  layout 'forum'

  def new
    @forum = Forum.find(params[:id])
    unless @forum.can_post?(@user)
      redirect_to :action => 'show', :id => @forum.id and return
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
    @location = @forum
    render '/post/new'
  end

  def show
    ppp    = ((@opts[:ppp] - 1) / @post_block_size + 1) * @post_block_size
    start  = params[:start].to_i - 1
    start  = 0 if (start <= 0)
    if (params[:page].to_i > 0 && !params[:start])
      start = (params[:page].to_i - 1) * ppp
      redirect_to :action => 'show', :id => params[:id], :start => start + 1, :status => :moved_permanently and return
    end
    rstart = (start/ppp)*ppp
    rend   = rstart + ppp - 1
    @range = rstart..rend
    # convert textual topic ids to numeric
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

    # try to get the requested topic or fail nicely
    begin
      @topic = Topic.find(tid)
      fid    = @topic.fid
    rescue
      render :partial => "not_found" and return
    end

    # redirect if needed
    # redirect if the topic has moved
    if (@topic.actual && @topic.id != @topic.actual.id)
      redirect_to :action => 'show', :id => @topic.actual.id and return
      # FIXME manage start and anchors too
    end

    # don't show 'start=1' if this is the first page (URL aesthetics!)
    if params[:start].to_i == 1
      redirect_to :action => 'show', :id => @topic.id and return
    end

    # avoid indexing permalinks as different pages
    if (start != rstart)
      redirect_to :action => 'show', :id => @topic.id and return if start < ppp
      redirect_to :action => 'show', :id => @topic.id, :start => rstart + 1 and return
    end

    # use the user's preferred engine
    if @preferred_engine == 1
      redirect_to @legacy_forum_uri + "/viewthread.php?tid=#{@topic.id}" \
        and return
    end


    # check access control once we have found the topic
    unless @topic.can_read?(@user)
      render :partial => "not_authorized" and return
    end

    if params[:page] == 'last'
      # XXX refactor here
      start  = @topic.total_posts - 1
      rstart = (start/ppp)*ppp
      rend   = rstart + ppp
      @range = rstart..rend
    end
    @page_seq_opts = { :last        => @topic.replies,
                       :ipp         => ppp,
                       :current     => start + 1,
                       :id          => tid,
                       :extra_links => [ :first, :forward, :back, :last ] }
    @location      = [ 'Topic', @topic ]
    @page_title    = @topic.subject
    @posts         = @topic.posts_range(@range, @user)
    @topic.increment!(:views)
  end

  def update
    @topic = Topic.find(params[:id].to_i)
    if request.xhr?
      if @topic.can_moderate? @user
        if params['topic']
          @topic.pinned = params['topic']['pinned'] == 'true' ? true : false
          @topic.locked = params['topic']['locked'] == 'true' ? true : false
          @topic.title  = params['topic']['title']
          new_fid       = params['topic']['fid'].to_i
          if @topic.fid != new_fid
            forum = Forum.find(new_fid)
            @topic.move_to(forum)
          end
        end
        @topic.save!
      end
      ppp            = ((@opts[:ppp] - 1) / @post_block_size + 1) * @post_block_size
      @location      = @topic
      @page_seq_opts = { :last        => @topic.replies + 1,
                         :action      => :show,
                         :ipp         => ppp,
                         #:current     => start + 1,
                         :id          => @topic.id,
                         :extra_links => [ :first, :forward, :back, :last ] }
      render :update do |page|
        page.replace_html 'moderator-panel-top', :partial => 'moderation_options'
        #page.replace_html 'breadcrumbs',         :partial => '/common/breadcrumbs'
        #page.replace_html 'breadcrumbs_bottom',  :partial => '/common/breadcrumbs'
      end
    end
  end

end
