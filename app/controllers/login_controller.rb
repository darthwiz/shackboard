class LoginController < ApplicationController
  # skip_before_filter :authenticate
  def index # {{{
  end # }}}
  def login # {{{
    username = params[:user][:username]
    password = params[:user][:password]
    user     = User.find_by_username(username)
    if (user) then
      if user.auth(password)
        session[:userid]          = user.id
        intended_action           = session[:intended_action]
        session[:intended_action] = nil
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
  end # }}}
  def logout # {{{
    reset_session
    redirect_to :back
  end # }}}
end
