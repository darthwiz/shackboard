# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :load_defaults
  private
  def load_defaults # {{{
    @settings = Settings.find_all[0]
    begin
      @user = User.find(session[:userid])
    rescue
      @user = nil
    end
    @opts     = {}
    if (@user) then
      ###### Custom user settings
      @opts[:ppp]   = @user.ppp.to_i || 30
      @opts[:tpp]   = @user.tpp.to_i || 30
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
  def authenticate # {{{
    if (session[:userid]) then
      @user = User.find(session[:userid])
    else
      session[:intended_action] = { :controller => controller_name, 
                                    :action     => action_name }
      redirect_to :controller => "login", :action => "index"
    end
  end # }}}
end
