class Admin::ForumsController < Admin::ApplicationController
  before_filter :authenticate
  layout 'forum'

  def index
    @forums     = Forum.find(:all, :conditions => 'fup = 0 OR fup IS NULL', :order => 'displayorder')
    @page_title = "Amministrazione forum - indice"
    @location   = [ :admin, @forums ]
  end

  def new
    begin
      parent_id = Forum.find(params[:parent]).id
    rescue
      parent_id = nil
    end
    @forum = Forum.new(:fup => parent_id)
    render :action => :edit
  end

  def edit
    @forum = Forum.find(params[:id])
    ensure_can_edit(@forum)
    @page_title = "Amministrazione forum - #{@forum.name}"
    @location   = [ :admin, @forum ]
  end

  def create
    @forum = Forum.new(params[:forum])
    ensure_can_edit(@forum)
    @forum.postperm = "1|1" # FIXME this really really sucks
    if @forum.save
      flash[:success] = "Forum creato correttamente."
    else
      flash[:error] = "Non è stato possibile creare il forum."
    end
    redirect_to admin_forums_path
  end

  def update
    @forum = Forum.find(params[:id])
    ensure_can_edit(@forum)
    @forum.description = params[:forum][:description]
    @forum.moderator   = params[:forum][:moderator]
    if @forum.update_attributes(params[:forum])
      flash[:success] = "Forum modificato correttamente."
    else
      flash[:model_errors] = @forum.errors
    end
    redirect_to admin_forums_path
  end

  def destroy
    @forum = Forum.find(params[:id])
    ensure_can_edit(@forum)
  end

  private

  def ensure_can_edit(forum)
    unless forum.can_edit?(@user)
      flash[:warning] = "Non sei autorizzato a modificare questo forum."
      redirect_to :action => :index
    end
  end

end
