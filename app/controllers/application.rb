# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :load_defaults, :update_online, :set_stylesheet
  private
  def cache_expire(params) # {{{
    case params[:object]
    when :topic # {{{
      tid = params[:id].to_i
      obj = Topic.find(tid)
      blk = obj.total_posts / @post_block_size
      expire_fragment("topic/#{obj.id}/#{blk}")
      expire_fragment("forum/#{obj.forum.id}/topics/0")
      while (obj = obj.container)
        f = obj if obj.is_a? Forum
      end
      expire_fragment("portal/#{f.id}")
      # }}}
    when :forum # {{{
      fid = params[:id].to_i
      obj = Forum.find(fid)
      expire_fragment("forum/#{obj.id}/topics/0")
      while (obj = obj.container)
        f = obj if obj.is_a? Forum
      end
      expire_fragment("portal/#{f.id}")
      # }}}
    end
  end # }}}
  def load_defaults # {{{
    @settings         = Settings.find_all[0]
    @post_block_size  = 25
    @topic_block_size = 25
    @legacy_forum_uri = LEGACY_FORUM_URI
    @host_forum       = @legacy_forum_uri.sub(/http:\/\/([^\/]+)\/.*/, "\\1")
    @preferred_engine = cookies[:forum_engine_version].to_i
    begin
      @user = User.find(session[:userid])
    rescue
      @user = nil
    end
    # legacy authentication {{{
    unless @user
      username         = cookies[:thisuser]
      password         = cookies[:thispw]
      @user            = User.authenticate(username, password)
      session[:userid] = @user.id if @user
    end
    # }}}
    @opts = {}
    if (@user) then
      ###### Custom user settings
      @opts[:ppp]   = @user.ppp.to_i || @post_block_size
      @opts[:tpp]   = @user.tpp.to_i || @post_block_size
      if @user.theme =~ /^http/
        @opts[:theme] = Theme.find_by_name(@settings.theme)
        @opts[:theme].css = @user.theme
      else
        @opts[:theme] = Theme.find_by_name(@user.theme)
      end
    else
      ###### Default settings
      @opts[:ppp]   = @settings.postperpage.to_i
      @opts[:tpp]   = @settings.topicperpage.to_i
      @opts[:theme] = Theme.find_by_name(@settings.theme)
    end
  end # }}}
  def set_stylesheet # {{{
    @stylesheet = url_for(
      :controller => controller_name,
      :action     => 'css',
      :id         => @opts[:theme].name
    )
  end # }}}
  def authenticate # {{{
    if (session[:userid])
      @user = User.find(session[:userid])
    else
      session[:intended_action] = { :controller => controller_name, 
                                    :action     => action_name }
      redirect_to :controller => "login", :action => "index"
    end
  end # }}}
  def is_authenticated? # {{{
    session[:userid] && User.find(session[:userid]).is_a?(User)
  end # }}}
  def forum_cache # {{{
    if (session[:forum_tree])
      Forum.set_tree(session[:forum_tree])
    else
      session[:forum_tree] = Forum.tree
    end
  end # }}}
  def update_online # {{{
    @current_user_ip = @request.env['REMOTE_ADDR']
    OnlineUser.touch(@user, @current_user_ip)
    OnlineUser.cleanup(5.minutes)
  end # }}}
end
