class UsersController < ApplicationController
  layout 'forum'
  skip_before_filter :clear_stale_fb_session, :only => [ :create, :fbconnect ]

  def index
    redirect_to root_path
  end

  def show
    @shown_user = User.find(params[:id])
    @location   = @shown_user
    tab         = params[:tab]
    case tab
    when 'profile', 'backup', 'delete'
      respond_to do |format|
        format.js { render :partial => tab }
      end
    when 'replies'
      if @shown_user == @user
        @posts = Post.with_recipient(@shown_user).range(0..50).ordered_by_time_desc
      else
        @posts = Post.with_recipient(@user).with_user(@shown_user).range(0..50).ordered_by_time_desc
      end
      respond_to do |format|
        format.js { render :partial => '/posts/by_user' }
      end
    else
      respond_to do |format|
        format.html do
          #@latest_replies = Post.find_replies_to_user(@shown_user, 1.month.ago, 50) if @shown_user == @user
          #@latest_posts   = @shown_user.posts.find(:all, :order => 'dateline DESC', :limit => 5)
        end
      end
    end
  end

  def new
    @new_user = User.new
    respond_to do |format|
      format.html do
        @rules = Settings.find(:first).bbrulestxt if params[:rules] == 'true'
      end
    end
  end

  def edit
    @edit_user = User.find(params[:id])
    @field     = params[:field].to_sym
    @edit_opts = { :type => params[:type].to_sym }
    li_id      = "edit_user_#{@field}"
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace li_id, :inline => "<%=profile_field_editor(@edit_user, @field, @edit_opts)%>"
        end
      end
    end
  end

  def create
    email     = params[:user][:email]
    email     = email.strip if email
    username  = params[:user][:username].strip
    password  = User.pwgen
    @new_user = User.new(
      :username => username,
      :password => password,
      :email    => email,
      :regip    => request.remote_ip,
      :regdate  => Time.now.to_i,
      :theme    => Settings.first.theme,
      :fbid     => params[:user][:fbid]
    )
    respond_to do |format|
      if @new_user.save
        Notifier.deliver_signup_notification(email, username, password) unless @new_user.email.blank?
        if @new_user.fbid
          flash[:success] = "La registrazione è avvenuta con successo."
        else
          flash[:success] = "La registrazione è avvenuta con successo. Riceverai a breve un e-mail con la tua password."
        end
        format.html { redirect_to root_path }
      else
        format.html do
          flash[:model_errors] = @new_user.errors
          if @new_user.fbid
            redirect_to :back
          else
            render :action => "new"
          end
        end
      end
    end
  end

  def login
    save_intended_action
  end

  def fbconnect
    save_intended_action
    if @user
      redirect_to_intended_action and return
    else
      @rules    = Settings.find(:first).bbrulestxt
      @new_user = User.new(:username => "#{@fb_user.first_name} #{@fb_user.last_name}", :fbid => @fb_user.id)
    end
  end

  def fblink
    username = params[:existing_user][:username]
    password = params[:existing_user][:password]
    fbid     = params[:existing_user][:fbid]
    user     = User.find_by_username(username)
    fb_user  = User.find_by_fbid(fbid)
    if !fb_user.nil?
      # this should never happen, but just in case someone is tampering...
      flash[:error] = "Il tuo account Facebook è già collegato a un utente."
      redirect_to(session[:intended_action] || root_path)
    elsif user && user.auth(password)
      user.fbid = fbid
      user.save!
      flash[:success] = "Il tuo utente è stato colegato all'account Facebook."
      redirect_to(session[:intended_action] || root_path)
    else
      flash[:error] = "L'autenticazione è fallita: riprova."
      redirect_to :back
    end
  end

  def authenticate
    username    = params[:users][:username]
    password    = params[:users][:password]
    cookie_time = params[:users][:cookie]
    cookie_time = cookie_time.to_i > 0 ? cookie_time.to_i : 10
    user        = User.find_by_username(username)
    if (user) then
      if user.auth(password)
        session[:userid]          = user.id
        intended_action           = session[:intended_action]
        session[:intended_action] = nil
        cookies[:thisuser]        = { :value => username, :domain => @@domain, :expires => Time.now + cookie_time.days }
        cookies[:thispw]          = { :value => password, :domain => @@domain, :expires => Time.now + cookie_time.days }
        if intended_action
          redirect_to intended_action
        else
          redirect_to :back
        end
      else
        redirect_to :controller => :users, :action => :login
      end
    else
      redirect_to :controller => :users, :action => :login
    end
  end

  def logout
    cookies[:thisuser] = { :domain => @@domain, :expires => Time.at(0) }
    cookies[:thispw]   = { :domain => @@domain, :expires => Time.at(0) }
    session[:facebook_session] = nil
    reset_session
    if request.referer
      redirect_to :back
    else
      redirect_to root_path
    end
  end

  def update
    # FIXME Some refactoring would be nice here.
    @edit_user = User.find(params[:id])
    if @edit_user.can_edit?(@user)
      if params[:user].is_a?(Hash)
        params[:user].each_pair { |key, value| @edit_user.send("#{key}=".to_sym, value) }
      else
        if (params[:new_password] == params[:confirm_password]) && (@user.is_adm? || @edit_user.password == params[:current_password])
          @edit_user.password = params[:new_password]
        else
          render :nothing => true and return
        end
      end
      @edit_user.save!
    end
    respond_to do |format|
      format.js do
        render :update do |page|
          if params[:user].is_a?(Hash)
            params[:user].each_pair do |key, value|
              @field     = key.to_sym
              @edit_opts = {}
              li_id      = "edit_user_#{@field}"
              page.replace li_id, :inline => "<%=editable_profile_field(@edit_user, @field, @edit_opts)%>"
            end
          elsif params[:new_password]
            @edit_opts = { :type => :password_field }
            page.replace 'edit_user_password', :inline => "<%=editable_profile_field(@edit_user, :password, @edit_opts)%>"
          end
        end
      end
    end
  end

  def recover_password
    @new_user = User.new
    respond_to do |format|
      format.html
    end
  end

  def send_password
    @email    = params[:user][:email]
    @new_user = User.find_by_email(@email) || User.new
    @new_user = User.new if @email.to_s.empty?
    @status   = :failure
    unless @new_user.new_record?
      Notifier.deliver_signup_notification(@email, @new_user.username, @new_user.password)
      @status = :success
    end
    render :action => :recover_password
  end

end
