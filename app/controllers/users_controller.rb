class UsersController < ApplicationController
  @@domain = COOKIE_DOMAIN
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
        redirect_to :controller => "login", :action => "index"
      end
    else
      redirect_to :controller => "login", :action => "index"
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

=begin
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
=end
end
