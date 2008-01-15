class CssController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :update_online,
    :set_stylesheet
  def view
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :layout => false
  end
end
