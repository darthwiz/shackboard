# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :set_facebook_session,
    :recognize_user, :load_defaults, :set_locale,
    :set_stylesheet
  after_filter :update_last_visit
  helper_method :facebook_session
  helper :all
  helper_method :is_adm?, :is_supermod?, :is_file_adm?
  @@domain = Conf.cookie_domain

  private

  def save_intended_action
    session[:intended_action] = request.referer unless request.referer == request.url
  end

  def redirect_to_intended_action
    destination = session[:intended_action]
    destination = root_path if !destination || destination == request.url
    redirect_to destination
  end

  def cache_expire(params)
    case params[:object]
    when :topic
      tid = params[:id].to_i
      obj = Topic.find(tid)
      blk = obj.total_posts / @post_block_size
      expire_fragment("topic/#{obj.id}/#{blk}")
      expire_fragment("forum/#{obj.forum.id}/topics/0")
      while (obj = obj.container)
        f = obj if obj.is_a? Forum
      end
      expire_fragment("portal/#{f.id}")

    when :forum
      fid = params[:id].to_i
      obj = Forum.find(fid)
      expire_fragment("forum/#{obj.id}/topics/0")
      while (obj = obj.container)
        f = obj if obj.is_a? Forum
      end
      expire_fragment("portal/#{f.id}")

    end
  end

  def is_adm?(user=@user)
    return false unless user.is_a? User
    user.is_adm?
  end

  def is_supermod?(user=@user)
    return false unless user.is_a? User
    user.is_supermod?
  end

  def is_file_adm?(user=@user)
    return false unless user.is_a? User
    FileController.new.send(:is_adm?, user)
  end

  def recognize_user
    begin
      @user = User.find(session[:userid])
    rescue
      @user = nil
    end

    # Facebook authentication
    @fb_session = session[:facebook_session]
    @fb_user    = @fb_session.user if @fb_session
    logger.debug 'trying to authenticate with Facebook'
    @user       = User.find_by_fbid(@fb_user.id) if (@fb_user && @user.nil?)
    logger.debug "user is #{@user.inspect}"

    # legacy authentication
    unless @user
      username         = cookies[:thisuser]
      password         = cookies[:thispw]
      @user            = User.authenticate(username, password)
      session[:userid] = @user.id if @user
    end

    # refresh legacy cookie
    # FIXME this clearly is a hack and should be phased out soon
    if @user.is_a? User
      cookies[:thisuser] = { :value => @user.username, :domain => @@domain, :expires => Time.now + 10.days }
      cookies[:thispw]   = { :value => @user.password, :domain => @@domain, :expires => Time.now + 10.days }
    end
  end

  def load_defaults
    @current_user_ip  = request.remote_ip
    @time_machine     = TimeMachine.new
    @settings         = Settings.find(:all)[0]
    @post_block_size  = 25
    @topic_block_size = 25
    @page_title       = Conf.default_page_title

    @opts = {}
    if @user
      # Custom user settings
      @opts[:ppp]   = @user.ppp.to_i || @post_block_size
      @opts[:tpp]   = @user.tpp.to_i || @post_block_size
      if @user.theme =~ /^http/
        @opts[:theme] = Theme.find_by_name(@settings.theme)
        @opts[:theme].css = @user.theme
      else
        theme_name = @user.theme.blank? ? @settings.theme : @user.theme
        @opts[:theme] = Theme.find_by_name(theme_name)
      end
    else
      # Default settings
      @opts[:ppp]   = Conf.posts_per_page
      @opts[:tpp]   = Conf.topics_per_page
      @opts[:theme] = Theme.find_by_name(Conf.default_theme)
    end

    # personal info
    if @user
      @unread_pms_count           = Pm.count_unread_for(@user)
      @unread_notifications_count = Notification.count_unread_for(@user)
      @unsent_drafts_count        = Draft.count_unsent_for(@user)
      @unapproved_files_count     = is_file_adm?(@user) ? FiledbFile.count_unapproved : 0
    end

    Notifier.delivery_method = :sendmail
  end

  def set_locale
    # see http://github.com/iain/http_accept_language/tree/master
    # locale = request.user_preferred_languages_from([ 'it_IT' ]) || 'en-US'
    # locale      = request.user_preferred_languages.first || 'it-IT'
    locale      = 'it-IT'
    I18n.locale = locale
  end

  def set_stylesheet
    @stylesheet = css_path(:name => @opts[:theme].name)
  end

  def authenticate
    if session[:userid]
      @user = User.find(session[:userid])
    elsif session[:facebook_session]
      @user = User.find_by_fbid(session[:facebook_session].user.id)
    else
      save_intended_action
      redirect_to login_users_path
    end
  end

  def is_authenticated?
    session[:userid] && User.find(session[:userid]).is_a?(User)
  end

  def clear_stale_fb_session
    unless @user
      session[:facebook_session] = nil
      reset_session
    end
  end

  def forum_cache
    if (session[:forum_tree])
      Forum.set_tree(session[:forum_tree])
    else
      session[:forum_tree] = Forum.tree
    end
  end

  def update_last_visit
    if @user.is_a?(User) && @location.is_a?(ActiveRecord::Base)
      return if @location.new_record? # XXX prevents saving an incomplete object, which triggers bugs
      LastVisit.cleanup(@user, @location)
      begin
        LastVisit.new(
          :user   => @user,
          :object => @location,
          :ip     => @current_user_ip
        ).save
      rescue
        logger.warn "WARNING: problem saving last visit record with location #{@location.inspect}"
      end
    end
  end

end
