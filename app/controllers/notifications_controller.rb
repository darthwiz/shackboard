class NotificationsController < ApplicationController
  layout 'forum'
  after_filter :mark_notifications_read, :only => :index

  def index
    ipp    = 50
    start  = params[:start].to_i - 1
    start  = 0 if (start <= 0)
    if (params[:page].to_i > 0 && !params[:start])
      start = (params[:page].to_i - 1) * ipp
      redirect_to :action => :index, :start => start + 1, :status => :moved_permanently and return
    end
    rstart         = (start/ipp)*ipp
    rend           = rstart + ipp - 1
    @range         = rstart..rend
    count          = Notification.with_recipient(@user).count
    @notifications = Notification.with_recipient(@user).range(@range).ordered_by_time_desc
    @page_seq_opts = { :last        => count,
                       :ipp         => ipp,
                       :current     => start + 1,
                       :extra_links => [ :first, :forward, :back, :last ] }
  end

  private

  def mark_notifications_read
    unless @notifications.blank?
      @notifications.each { |n| n.update_attribute(:seen, true) }
    end
  end

end
