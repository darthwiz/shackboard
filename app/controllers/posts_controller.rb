class PostsController < ApplicationController
  before_filter :authenticate, :except => :show

  def show
    @post = Post.find(params[:id])
    @page_title = @post.topic.title
    @post.message = '[ messaggio cancellato ]' if @post.deleted_by && !@user.is_adm?
    respond_to do |format|
      format.html { render :layout => 'forum' }
      format.xml  { render :xml => @post }
    end
  end

=begin
  def view
    post  = Post.find(params[:id])
    conds = [ 'tid = ? AND fid = ? AND dateline <= ?
      AND deleted_by IS NULL', post.tid, post.fid, post.dateline ]
    start = Post.count(:conditions => conds)
    redirect_to :controller => 'topic', :action => 'view', :id => post.topic.id,
      :start => start, :anchor => "post_#{post.id}"
  end

  def new 
    repclass = params[:class]
    reply_id = params[:reply].to_i
    draft_id = params[:draft].to_i
    quote    = (params[:quote] == 'true') ? true : false
    @post    = Post.new
    if reply_id > 0
      if repclass == 'post'
        reply_to = Post.find(reply_id)
        if reply_to.can_post?(@user)
          @post.fid          = reply_to.fid
          @post.tid          = reply_to.tid
          @post.reply_to_pid = reply_to.pid
          @post.reply_to_uid = reply_to.uid
          @post.message = (reply_to.format == 'bb') ? 
            "[quote][b]Originariamente inviato da " + 
            "#{reply_to.user.username}[/b]\n" +
            reply_to.message + "[/quote]" : reply_to.message if quote
        else
          @location = [ 'Topic', reply_to.topic ]
          render :layout => 'forum', :template => 'not_permitted' and return
        end
      elsif repclass == 'topic'
        reply_to = Topic.find(reply_id)
        if reply_to.can_post?(@user)
          @post.fid          = reply_to.fid
          @post.tid          = reply_to.tid
          @post.reply_to_pid = 0
          @post.reply_to_uid = 0
        else
          @location = [ 'Topic', reply_to ]
          render :layout => 'forum', :template => 'not_permitted' and return
        end
      end
    end
    if draft_id > 0
      conds  = [ 'id = ? AND object_type = ? AND user_id = ?', draft_id, 'Post',
        @user.id ]
      @draft = Draft.find(:first, :conditions => conds) || Draft.new
      @post  = @draft.object[0] if @draft.object.is_a? Array
    else
      @draft             = Draft.new
      @draft.user        = @user
      @draft.timestamp   = Time.now.to_i
      @draft.object      = [ @post ]
      @draft.object_type = @post.class.to_s
      @draft.save!
    end
    @location = [ 'Forum', @post.forum, :new ]
    @location = [ 'Topic', @post.topic, :reply ] if @post.topic
    render :layout => 'forum'
  end 

  def create 
    forum_id           = params[:forum_id].to_i
    topic_id           = params[:topic_id].to_i
    @post              = Post.new(params[:post])
    @post[:subject]    = params[:post][:subject]
    @post.dateline     = Time.now.to_i
    @post.usesig       = "yes"
    @post.uid          = @user.id
    @post.useip        = request.remote_ip
    @post.forum        = Forum.find(forum_id)
    @post.topic        = topic_id > 0 ? Topic.find(topic_id) : nil
    @post.reply_to_pid = params[:reply_to_pid]
    @post.reply_to_uid = params[:reply_to_uid]
    if @post.topic.is_a? Topic
      if !@post.topic.can_post?(@user)
        render :layout => 'forum', :action => 'not_permitted' and return
      elsif @post.save
        cache_expire({:object => :topic, :id => @post.topic.id})
        @post.user.increment! :postnum
        Draft.destroy(params[:draft_id]) # FIXME need better security here
        redirect_to :controller => 'topic', :action => 'view', 
                    :id => @post.topic.id, :anchor => "post_#{@post.id}",
                    :start => @post.topic.posts_count_cached
      else
      end
    else
      new_topic = Topic.new
      attr_list = (Topic.new.attribute_names & Post.new.attribute_names).
        collect { |n| n.to_sym } << :subject
      attr_list.each { |a| new_topic[a] = @post[a] }
      new_topic.lastpost = {
        :user      => @user,
        :timestamp => new_topic.dateline,
      }
      if !new_topic.can_post?(@user)
        render :layout => 'forum', :action => 'not_permitted' and return
      elsif new_topic.save
        cache_expire({:object => :forum, :id => new_topic.forum.id})
        @post.user.increment! :postnum
        Draft.destroy(params[:draft_id]) # FIXME need better security here
        redirect_to :controller => 'topic', :action => 'view', 
                    :id => new_topic.id, :anchor => "post_#{@post.id}",
                    :start => new_topic.posts_count_cached
      else
      end
    end
  end 

  def edit
    @post = Post.find(params[:id])
    respond_to do |format|
      format.html do
        unless @post.can_edit?(@user)
          redirect_to :controller => 'post', :action => 'view', :id => @post.id
        else
          @location = [ 'Topic', @post.topic, :edit ]
          render :template => "/post/new", :layout => 'forum'
        end
      end
      format.js do
        render :update do |page|
          page.replace_html "post_#{@post.id}_text", :partial => 'edit_in_place'
        end
      end
    end 
  end 

  def update
    @post = Post.find(params[:post][:id].to_i)
    return unless @post.can_edit?(@user)
    @post.text     = params[:post][:text]
    @post.editdate = Time.now.to_i
    @post.edituser = @user.id
    @post.save!
    respond_to do |format|
      format.html do
        redirect_to :controller => 'post', :action => 'view', :id => @post
      end
      format.js do
        render :update do |page|
          page.replace_html "post_#{@post.id}_text", :inline => "<%=text_to_html(@post.message)%>"
        end
      end
    end
  end 

  def delete 
    if request.xml_http_request?
    else
      render :nothing => true and return
    end
  end 

  def save_draft 
    if request.xml_http_request?
      Post.new # this is needed to load the Post class, otherwise d.object won't
               # be an instance of Post, but of YAML::Object instead
      id    = params[:draft_id]
      conds = ['user_id = ?', @user.id]
      d     = Draft.find(id, :conditions => conds ) || Draft.new
      if (d.user == @user)
        d.object[0].message   = params[:post][:message]
        d.object[0][:subject] = params[:post][:subject]
        d.timestamp           = Time.now.to_i
        # NOTE: everything else should already be defined at this point.
        d.save
      end
      @draft = d
      render :partial => 'save_draft'
    else
      render :nothing => true and return
    end
  end 

  def nonsense 
    username  = params[:id]
    u         = User.find_by_username(username) if username
    u         = u ? u : @user
    d         = Dadadodo.new 
    d.user    = u
    d.posts   = 50
    @nonsense = d.nonsense
  end 

  private
  def id_to_object(id) 
    arr = id.split(/_/)
    return nil unless ['post', 'topic'].include? arr[0]
    begin
      obj = Module.const_get(arr[0].capitalize).find(arr[1].to_i)
    rescue
      obj = nil
    end
  end 
=end
end
