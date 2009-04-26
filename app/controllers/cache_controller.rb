class CacheController < ApplicationController

  def expire(p=params)
    tid = p[:id].to_i
    cache_expire({:object => :topic, :id => tid})
    render :nothing => true
  end

end
