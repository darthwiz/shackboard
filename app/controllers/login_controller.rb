class LoginController < ApplicationController
  # skip_before_filter :authenticate
  @@domain = COOKIE_DOMAIN
  def index 
  end 
  def login 
    username = params[:user][:username] if params[:user]
    password = params[:user][:password] if params[:user]
    user     = User.find_by_username(username)
    if (user) then
      if user.auth(password)
        session[:userid]          = user.id
        intended_action           = session[:intended_action]
        session[:intended_action] = nil
        cookies[:thisuser]        = { :value => username, :domain => @@domain, :expires => Time.now + 10.days }
        cookies[:thispw]          = { :value => password, :domain => @@domain, :expires => Time.now + 10.days }
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
      render :nothing => true
    end
  end 
end
