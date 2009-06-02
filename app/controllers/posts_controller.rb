class PostsController < ApplicationController
  before_filter :authenticate, :except => :show
  layout 'forum'

  def show
    @post = Post.secure_find(params[:id], @user)
    @page_title = @post.topic.title
    @post.message = '[ messaggio cancellato ]' if @post.deleted_by && !@user.is_adm?
    respond_to do |format|
      format.html do
        @location   = @post
        @page_title = @post.topic.title
      end
      format.xml { render :xml => @post }
    end
  end

  def reply
    reply_to = Post.secure_find(params[:id], @user)
    @topic   = reply_to.topic
    @post    = Post.new(
      :topic        => @topic,
      :reply_to_pid => reply_to.pid,
      :reply_to_uid => reply_to.uid,
      :message      => "[quote][b]Originariamente inviato da #{reply_to.user.username}[/b]\n#{reply_to.message}[/quote]\n"
    )
    @draft = Draft.new(:object => @post, :user => @user)
    @draft.save!
    respond_to do |format|
      format.html do
        @latest_posts = @topic.latest_posts(10).reverse
        render :action => 'new'
      end
    end
  end

  def new
    draft_id = params[:draft_id].to_i
    topic_id = params[:topic_id].to_i
    if draft_id > 0
      @draft = Draft.secure_find(draft_id, @user)
      @topic = @draft.object.topic if @draft.object.topic_id > 0
      @post  = @draft.object
    elsif topic_id > 0
      @topic = Topic.secure_find(topic_id, @user)
      @post  = Post.new(
        :topic => @topic,
        :reply_to_pid => 0,
        :reply_to_uid => 0
      )
      @draft = Draft.new(:object => @post, :user => @user)
      @draft.save!
    end
    respond_to do |format|
      format.html do
        @latest_posts = @topic.latest_posts(10).reverse
      end
    end
  end

  def edit
    @post  = Post.secure_find_for_edit(params[:id], @user)
    @topic = @post.topic
    ## TODO we don't use drafts on editing right now
    #@draft = Draft.new(
    #  :object      => @post,
    #  :user        => @user
    #)
    #@draft.save!
    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end

  def save_draft
    @draft        = Draft.secure_find(params[:draft_id], @user)
    @draft.object = Post.new(params[:post])
    @draft.save
    respond_to do |format|
      format.html { render :partial => '/drafts/save_draft' }
    end
  end

  def create
    @post  = Post.new(params[:post])
    @draft = Draft.secure_find(params[:draft_id], @user)
    if @post.topic.can_post?(@user)
      @post.dateline = Time.now.to_i
      @post.useip    = request.remote_ip
      @post.usesig   = 'yes'
      @post.forum    = @post.topic.forum
      @post.user     = @user
      @post.save!
      @draft.destroy
      respond_to do |format|
        format.html { redirect_to topic_path(@post.topic, :page => 'last', :anchor => 'last_post') }
      end
      @post.topic.update_last_post!
      @post.forum.update_last_post!
      @post.user.increment!(:postnum)
      cache_expire({:object => :topic, :id => @post.topic.id})
    end
  end

  def update
    @post  = Post.secure_find_for_edit(params[:post][:id], @user)
    #@draft = Draft.secure_find(params[:draft_id], @user) # TODO support drafts
    if @post.can_edit?(@user)
      @post.edituser = @user.id
      @post.editdate = Time.now.to_i
      @post.message  = params[:post][:message]
      @post.save!
      #@draft.destroy
      respond_to do |format|
        format.html { redirect_to topic_path(@post.topic, :start => @post.find_seq, :anchor => "pid#{@post.id}") }
      end
    end
  end

  def destroy
    @post = Post.secure_find_for_edit(params[:id], @user)
    if @post.can_edit?(@user)
      seq = [ @post.find_seq - 2, 0 ].max
      pid = @post.topic.posts_range(seq..seq).first.id
      @post.delete(@user)
      cache_expire({:object => :topic, :id => @post.topic.id})
      respond_to do |format|
        format.html { redirect_to topic_path(@post.topic, :start => seq, :anchor => "pid#{pid}") }
      end
    end
  end

end
