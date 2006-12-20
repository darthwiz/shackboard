class CacheController < ApplicationController
  def expire # {{{
    tid = params[:id].to_i
    obj = Topic.find(tid)
    while (obj = obj.container)
      f = obj if obj.is_a? Forum
    end
    case f.id
    when 25
      expire_fragment(:controller => 'forum', :action => 'forums')
    when 24
      expire_fragment(:controller => 'forum', :action => 'channels')
    when 51
      expire_fragment(:controller => 'forum', :action => 'boards')
    when 108
      expire_fragment(:controller => 'forum', :action => 'market')
    end
    render :nothing => true
  end # }}}
end
