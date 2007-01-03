class PostController < ApplicationController
  before_filter :authenticate
  def extra_cmds # {{{
    if @request.xml_http_request?
      obj = id_to_object(params[:id])
      render :partial => 'extra_cmds', :locals => { :obj => obj } and return
    else
      render :nothing => true and return
    end
  end # }}}
  def delete # {{{
    if @request.xml_http_request?
    else
      render :nothing => true and return
    end
  end # }}}
  private
  def id_to_object(id) # {{{
    arr = id.split(/_/)
    return nil unless ['post', 'topic'].include? arr[0]
    begin
      obj = Module.const_get(arr[0].capitalize).find(arr[1].to_i)
    rescue
      obj = nil
    end
  end # }}}
end
