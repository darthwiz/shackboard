class ForumsController < ApplicationController
  layout 'forum'

  def index
    @forums     = Forum.find(:all, :conditions => 'fup = 0', :order => 'displayorder')
    @topics     = []
    @page_title = "Indice dei forum"
    @location   = @forums
    render :action => :show
  end

  def show
    tpp    = @opts[:tpp]
    start  = params[:start].to_i - 1
    start  = 0 if (start <= 0)
    if (params[:page].to_i > 0 && !params[:start])
      start = (params[:page].to_i - 1) * tpp
      redirect_to :action => :show, :id => params[:id], :start => start + 1, :status => :moved_permanently and return
    end
    rstart      = (start/tpp)*tpp
    rend        = rstart + tpp - 1
    @range      = rstart..rend
    @forum      = Forum.find(params[:id])
    @forums     = Forum.find(:all, :conditions => [ 'fup = ?', params[:id] ], :order => 'displayorder')
    @topics     = @forum.topics_range(@range)
    @page_title = @forum.name
    @location   = @forum
  end

end
