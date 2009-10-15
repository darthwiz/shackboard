class Admin::ForumsController < Admin::ApplicationController
  before_filter :authenticate
  layout 'forum'

  def index
    @forums     = Forum.find(:all, :conditions => 'fup = 0', :order => 'displayorder')
    @page_title = "Amministrazione forum - indice"
    @location   = [ :admin, @forums ]
  end

  def new
  end

  def edit
    @forum = Forum.find(params[:id])
    ensure_can_edit(@forum)
    @page_title = "Amministrazione forum - #{@forum.name}"
    @location   = [ :admin, @forum ]
  end

  def create
  end

  def update
    @forum = Forum.find(params[:id])
    ensure_can_edit(@forum)
    @forum.description = params[:forum][:description]
    @forum.moderator   = params[:forum][:moderator]
    if @forum.update_attributes(params[:forum])
      flash[:success] = "Forum modificato con successo."
    else
      flash[:model_errors] = @forum.errors
    end
    redirect_to admin_forums_path
  end

  def destroy
  end

  private

  def ensure_can_edit(forum)
    unless forum.can_edit?(@user)
      flash[:warning] = "Non sei autorizzato a modificare questo forum."
      redirect_to :action => :index
    end
  end

end
