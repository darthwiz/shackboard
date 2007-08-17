class PostController < ApplicationController
  before_filter :authenticate
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
  def new # {{{
    reply_id = params[:reply].to_i
    draft_id = params[:draft].to_i
    repclass = params[:class]
    quote    = (params[:quote] == 'true') ? true : false
    @post    = Post.new
    case repclass
    when 'post'
      reply_to = Post.find(reply_id)
    when 'topic'
      reply_to = Topic.find(reply_id)
    end
    if (repclass && reply_to.can_post?(@user))
      @post.fid     = reply_to.fid
      @post.tid     = reply_to.tid
      @post.message = (reply_to.format == 'bb') ? 
        "[quote][b]Originariamente inviato da #{reply_to.user.username}[/b]\n" +
        reply_to.message + "[/quote]" : reply_to.message if quote
    end
    if draft_id > 0
      conds  = [ 'id = ? AND object_type = ? AND user_id = ?', draft_id, 'Post',
        @user.id ]
      @draft = Draft.find(:first, :conditions => conds) || Draft.new
      @post  = @draft.object if @draft.object
    else
      @draft           = Draft.new
      @draft.user      = @user
      @draft.timestamp = Time.now.to_i
      @draft.object    = @post
      @draft.save
    end
    @location = [ 'Forum', @post.forum, :new ]
    @location = [ 'Topic', @post.topic, :reply ] if @post.topic
  end # }}}
  def extra_cmds # {{{
    if @request.xml_http_request?
      obj = id_to_object(params[:id])
      render :partial => 'extra_cmds', :locals => { :obj => obj } and return
    else
      render :nothing => true and return
    end
  end # }}}
  def create # {{{
    forum_id        = params[:forum_id].to_i
    topic_id        = params[:topic_id].to_i
    @post           = Post.new(params[:post])
    @post[:subject] = params[:post][:subject]
    @post.dateline  = Time.now.to_i
    @post.usesig    = "yes"
    @post.author    = @user.username
    @post.useip     = @request.env['REMOTE_ADDR']
    @post.forum     = Forum.find(forum_id)
    @post.topic     = topic_id > 0 ? Topic.find(topic_id) : nil
    if @post.topic.is_a? Topic
      cache_expire({:object => :topic, :id => @post.topic.id})
      if @post.save
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
      if new_topic.save
        cache_expire({:object => :forum, :id => new_topic.forum.id})
        Draft.destroy(params[:draft_id]) # FIXME need better security here
        redirect_to :controller => 'topic', :action => 'view', 
                    :id => new_topic.id, :anchor => "post_#{@post.id}",
                    :start => new_topic.posts_count_cached
      else
      end
    end
  end # }}}
  def delete # {{{
    if @request.xml_http_request?
    else
      render :nothing => true and return
    end
  end # }}}
  def save_draft # {{{
    if @request.xml_http_request?
      Post.new # this is needed to load the Post class, otherwise d.object won't
               # be an instance of Post, but of YAML::Object instead
      id    = params[:draft_id]
      conds = ['user_id = ?', @user.id]
      d     = Draft.find(id, :conditions => conds ) || Draft.new
      if (d.user == @user)
        d.object.message   = params[:post][:message]
        d.object[:subject] = params[:post][:subject]
        d.timestamp        = Time.now.to_i
        # NOTE: everything else should already be defined at this point.
        d.save
      end
      @draft = d
      render :partial => 'save_draft'
    else
      render :nothing => true and return
    end
  end # }}}
  def nonsense # {{{
    username  = params[:id]
    u         = User.find_by_username(username) if username
    u         = u ? u : @user
    d         = Dadadodo.new 
    d.user    = u
    d.posts   = 50
    @nonsense = d.nonsense
  end # }}}
  private
  def id_to_object(id) # {{{
    arr = id.split(/_/)
    return nil unless ['post', 'topic'].include? arr[0]
    begin
      obj = Module.const_get(arr[0].capitalize).find(arr[1].to_i)
    rescue
      obj = nil
    end
  end # }}}
end
