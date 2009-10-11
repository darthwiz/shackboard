class AnnouncementsController < ApplicationController
  layout 'forum'

  def index
    @announcements = Announcement.find(:all, :order => 'date DESC')
    @page_title    = 'Indice degli annunci'
    @location      = @announcements
  end

  def show
    @announcement = Announcement.find(params[:id])
    @page_title   = @announcement.title
    @location     = @announcement
    @announcement.increment!(:num_views)
  end

end
