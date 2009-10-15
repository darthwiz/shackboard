class Admin::AnnouncementsController < Admin::ApplicationController
  before_filter :authenticate
  layout 'forum'

  def index
    @announcements = Announcement.find(:all, :order => 'date DESC')
    @page_title    = "Amministrazione annunci"
    @location      = [ :admin, @announcements ]
  end

  def new
    @announcement = Announcement.new
    ensure_can_edit(@announcement)
    @location = [ :admin, @announcement ]
    render :action => :edit
  end

  def edit
    @announcement = Announcement.find(params[:id])
    ensure_can_edit(@announcement)
    @location = [ :admin, @announcement ]
  end

  def create
    @announcement = Announcement.new(params[:announcement])
    ensure_can_edit(@announcement)
    @announcement.poster = @user.username
    @announcement.date   = Time.now.to_i
    if @announcement.save
      flash[:success] = "Annuncio creato con successo."
      redirect_to admin_announcements_path
    else
      flash[:model_errors] = @announcement.errors
      @location            = [ :admin, @announcement ]
      render :action => :edit
    end
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
      msg = "Non sei autorizzato a modificare questo annuncio."
      msg = "Non sei autorizzato a creare un nuovo annuncio." if announcement.new_record?
      flash[:warning] = msg
      redirect_to :action => :index
    end
  end

end
