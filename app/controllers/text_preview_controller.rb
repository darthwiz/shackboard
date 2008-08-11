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
end
