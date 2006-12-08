class ThemeController < ApplicationController
  def css # {{{
    @headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name              = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end # }}}
end
