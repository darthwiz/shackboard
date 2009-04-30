class UsersController < ApplicationController
  layout 'forum'
  # GET /users/1
  # GET /users/1.xml
  def show
    @shown_user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @new_user = User.new
    respond_to do |format|
      format.html do
        @rules = Settings.find(:first).bbrulestxt if params[:rules] == 'true'
        render :layout => 'forum'
      end
    end
  end

  # GET /users/1/edit
  def edit
    @edit_user = User.find(params[:id])
    unless @edit_user == @user || @user.is_adm?
      redirect_to user_path(@edit_user) and return
    end
    respond_to do |format|
      format.html
    end
  end

  # POST /users
  # POST /users.xml
  def create
    email     = params[:user][:email].strip
    username  = params[:user][:username].strip
    password  = User.pwgen
    @new_user = User.new(
      :username => username,
      :password => password,
      :email    => email,
      :regip    => request.remote_ip,
      :regdate  => Time.now.to_i
    )
    respond_to do |format|
      if @new_user.save
        Notifier.delivery_method = :sendmail
        Notifier.deliver_signup_notification(email, username, password)
        format.html { render :layout => 'forum' }
      else
        format.html { render :action => "new", :layout => 'forum' }
      end
    end
  end

  def login
    session[:intended_action] = request.env['HTTP_REFERER']
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
    reset_session
    if request.env["HTTP_REFERER"]
      redirect_to :back 
    else
      redirect_to root_path
    end
  end 

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @edit_user = User.find(params[:id])
    respond_to do |format|
      if @edit_user == @user || @user.is_adm?
        if @edit_user.update_attributes(params[:user])
          #flash[:notice] = 'User was successfully updated.'
          new_password = params[:new_password].to_s
          unless new_password.empty?
            @edit_user.password = new_password
            @edit_user.save
          end
          format.html { redirect_to(@edit_user) }
          #format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          #format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      else
        redirect_to @edit_user
      end
    end
  end

end
