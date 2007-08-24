class EngineController < ApplicationController
  @@domain = COOKIE_DOMAIN
  def switch # {{{
    topic = params[:topic]
    forum = params[:forum]
    p [topic, forum]
    if topic
      cookies[:forum_engine_version] = {:value => '1', :domain => @@domain,
        :expires => 2.days.from_now }
      redirect_to @legacy_forum_uri + "/viewthread.php?tid=#{topic}" \
        and return
    elsif forum
      cookies[:forum_engine_version] = {:value => '1', :domain => @@domain,
        :expires => 2.days.from_now }
      redirect_to @legacy_forum_uri + "/forumdisplay.php?fid=#{forum}" \
        and return
    else
      redirect_to :back and return
    end
  end # }}}
end
