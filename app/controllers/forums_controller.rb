class ForumsController < ApplicationController
  layout 'forum'

  def index
    @forums     = Forum.find(:all, :conditions => 'fup = 0', :order => 'displayorder')
    @topics     = []
    @page_title = "Indice dei forum"
    @location   = @forums
  end

  def show
    tpp    = @opts[:tpp]
    start  = params[:start].to_i - 1
    start  = 0 if (start <= 0)
    if (params[:page].to_i > 0 && !params[:start])
      start = (params[:page].to_i - 1) * tpp
      redirect_to :action => :show, :id => params[:id], :start => start + 1, :status => :moved_permanently and return
    end
    rstart = (start/tpp)*tpp
    rend   = rstart + tpp - 1
    @range = rstart..rend
    # convert textual forum ids to numeric 
    fid = params[:id].to_i
    if (fid <= 0) then
      forum = Forum.find(
        :first,
        :conditions => ['name LIKE ?', '%' + params[:id].to_s + '%'],
        :order => 'posts DESC'
      )
      if (forum.is_a? Forum) then
        fid = forum.id
      end
    end
    # try to get the requested forum or fail nicely 
    begin
      @forum = Forum.find(fid)
    rescue
      render :partial => "not_found" and return
    end
    @forum = Forum.find(params[:id])
    render :partial => "not_authorized" and return unless @forum.can_read?(@user)
    @forums         = Forum.find(:all, :conditions => [ 'fup = ?', params[:id] ], :order => 'displayorder')
    @announcements  = Announcement.find_latest(2)
    @topics         = @forum.topics_range(@range)
    @banned_users   = User.banned_from_forum_at_time(@forum, Time.now)
    @page_title     = @forum.name
    @popular_topics = @forum.popular_topics
    @location       = @forum
    @page_seq_opts  = { :last    => @forum.topics_count_cached,
                        :ipp     => tpp,
                        :current => start + 1,
                        :id      => fid }
  end

end
