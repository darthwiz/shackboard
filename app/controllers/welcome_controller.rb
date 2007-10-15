class WelcomeController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :update_online,
    :set_stylesheet, :only => [ :css ]
  def index 
  end 
  def css 
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end 
end
