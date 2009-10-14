class Admin::AnnouncementsController < Admin::ApplicationController
  before_filter :authenticate
  layout 'forum'

  def index
    @announcements = Announcement.all
    @page_title = "Amministrazione annunci"
    @location   = [ :admin, @forums ]
  end

  def new
  end

  def edit
    @announcement = Announcement.find(params[:id])
    ensure_can_edit(@announcement)
    @location = [ :admin, @announcement ]
  end

  def create
  end

  def update
    @announcement = Announcement.find(params[:id])
    ensure_can_edit(@announcement)
    if @announcement.update_attributes(params[:announcement])
      flash[:success] = "Annuncio modificato con successo."
    else
      flash[:model_errors] = @announcement.errors
    end
    redirect_to admin_announcements_path
  end

  def destroy
  end

  private

  def ensure_can_edit(announcement)
    unless announcement.can_edit?(@user)
      flash[:warning] = "Non sei autorizzato a modificare questo annuncio."
      redirect_to :action => :index
    end
  end

end
