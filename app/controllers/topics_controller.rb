class TopicsController < ApplicationController
  before_filter :authenticate, :except => :show
  layout 'forum'

  def new
    @forum = Forum.find(params[:forum_id])
    unless @forum.can_post?(@user)
      flash[:warning] = "Non hai il permesso di aprire una nuova discussione in questo forum."
      redirect_to @forum and return
    end
    draft_id       = params[:draft].to_i
    @topic         = Topic.new
    @topic.forum   = @forum
    @topic.message = ''
    if draft_id > 0
      @draft = Draft.secure_find(draft_id, @user)
      @topic = @draft.object if @draft.object
    else
      @draft = Draft.new(:user => @user, :object => @topic)
      @draft.save!
    end
    @location = @topic
  end

  def show
    #ppp    = ((@opts[:ppp] - 1) / @post_block_size + 1) * @post_block_size
    ppp    = @opts[:ppp]
    start  = params[:start].to_i - 1
    start  = 0 if (start <= 0)
    if (params[:page].to_i > 0 && !params[:start])
      start = (params[:page].to_i - 1) * ppp
      redirect_to :action => :show, :id => params[:id], :start => start + 1, :status => :moved_permanently and return
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
      flash[:error] = "La discussione non è stata trovata."
      redirect_to forum_root_path and return
    end

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

    # redirect to the numeric topic id unless we're already using it
    unless params[:id].to_i > 0
      redirect_to :action => 'show', :id => @topic.id, :start => rstart + 1 and return
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
    @location      = @topic
    @page_title    = @topic.subject
    @post_icons    = Smiley.post_icons
    @posts         = @topic.posts_range(@range, @user)
    @topic.increment!(:views)
    respond_to do |format|
      format.html
      format.txt
      format.xml { render :xml => @post }
    end
  end

  def update
    @topic = Topic.find(params[:id].to_i)
    if request.xhr?
      if @topic.can_edit? @user
        if params['topic']
          @topic.title  = params['topic']['title']
          @topic.icon   = params['topic']['icon'] == 'on' ? nil : params['topic']['icon']
        end
      end
      if @topic.can_moderate? @user
        if params['topic']
          @topic.pinned = params['topic']['pinned'] == 'true' ? true : false
          @topic.locked = params['topic']['locked'] == 'true' ? true : false
          new_fid       = params['topic']['fid'].to_i
          if new_fid > 0 && @topic.fid != new_fid
            forum = Forum.find(new_fid)
            @topic.move_to(forum)
          end
        end
      end
      @topic.save!
      ppp            = ((@opts[:ppp] - 1) / @post_block_size + 1) * @post_block_size
      @location      = @topic
      @post_icons    = Smiley.post_icons
      @page_seq_opts = { :last        => @topic.replies + 1,
                         :action      => :show,
                         :ipp         => ppp,
                         #:current     => start + 1,
                         :id          => @topic.id,
                         :extra_links => [ :first, :forward, :back, :last ] }
      render :update do |page|
        page.replace_html 'moderator-panel-top', :partial => 'moderation_options', :locals => { :can_moderate => @topic.can_moderate?(@user) }
        #page.replace_html 'breadcrumbs',         :partial => '/common/breadcrumbs'
        #page.replace_html 'breadcrumbs_bottom',  :partial => '/common/breadcrumbs'
      end
    end
  end

  def create
    @topic = Topic.new(params[:topic])
    @draft = Draft.secure_find(params[:draft_id], @user)
    if @topic.forum.can_post?(@user)
      time    = Time.now.to_i
      ip_addr = request.remote_ip
      @topic.dateline = time
      @topic.useip    = ip_addr
      @topic.forum    = @topic.forum
      @topic.user     = @user
      @topic.subject  = @topic.subject =~ /[a-z]/ ? @topic.subject : @topic.subject.split(/\s/).collect(&:capitalize).join(' ')
      @topic.save!
      @post              = Post.new
      @post.topic        = @topic
      @post.dateline     = time
      @post.useip        = ip_addr
      @post.usesig       = 'yes'
      @post.forum        = @topic.forum
      @post.user         = @user
      @post.message      = params[:topic][:message]
      @post.reply_to_pid = 0
      @post.reply_to_uid = 0
      @post.save!
      @draft.destroy
      @post.topic.update_last_post!(@post)
      @post.forum.update_last_post!(@post)
      @post.user.increment!(:postnum)
      cache_expire({:object => :topic, :id => @post.topic.id})
      respond_to do |format|
        format.html { redirect_to topic_path(@post.topic, :page => 'last', :anchor => 'last_post') }
      end
    end
  end

  def destroy
    begin
      @topic = Topic.find(params[:id])
    rescue
      flash[:error] = "La discussione non è stata trovata."
      redirect_to forum_root_path and return
    end
    if @topic.can_delete?(@user)
      @topic.delete(@user)
      flash[:warning] = "La discussione è stata cancellata."
      cache_expire({:object => :forum, :id => @topic.forum.id})
      redirect_to @topic.forum
    else
      flash[:error] = "Non hai il permesso di cancellare questa discussione."
      redirect_to :back
    end
  end
 
  def save_draft
    @draft                = Draft.secure_find(params[:draft_id], @user)
    @draft.object         = Topic.new(params[:topic])
    @draft.object.message = params[:topic][:message] # must be done explicitly
    @draft.save!
    respond_to do |format|
      format.html { render :partial => '/drafts/save_draft' }
    end
  end

  def full
    render :nothing and return unless @user.is_a? User
    @topic = Topic.find(params[:id])
    @posts = @topic.posts_range(0..(@topic.posts_count))
    respond_to do |format|
      format.txt { render :action => :show }
    end
  end

end
