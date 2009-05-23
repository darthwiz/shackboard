class CssController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :update_online,
    :set_stylesheet
  def view
    headers["Content-Type"] = 'text/css; charset = utf-8'
    theme_name              = params[:name].sub(/\.css$/, "")
    @theme                  = Theme.find_by_name(theme_name)
    @theme                  = Theme.find_by_name('studentibicocca') unless @theme.is_a? Theme
    render :layout => false
  end
end
