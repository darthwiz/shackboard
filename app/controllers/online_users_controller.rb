class OnlineUsersController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :set_stylesheet
  before_filter :update_with_current

  def index
    @online_users = OnlineUser.online
    @guests_count = OnlineUser.guests_count
    render :partial => 'list'
  end

  private

  def update_with_current
    OnlineUser.touch(@user, request.remote_ip)
    OnlineUser.cleanup(5.minutes)
  end

end
