class TextPreviewController < ApplicationController
  def text_to_html 
    if request.xml_http_request?
      @text          = {}
      p              = params[:post] || params[:pm]
      @text[:text]   = p[:message]
      @text[:format] = p[:format]
      render :partial => 'text_to_html' and return
    else
      render :nothing => true and return
    end
  end 
  def scratchpad 
  end 
  def css 
    headers["Content-Type"] = 'text/css; charset = utf-8'
    @theme_name             = params[:id].sub(/\.css$/, "")
    render :partial => 'css'
  end 
end
