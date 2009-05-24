class Admin::CmsPagesController < Admin::ApplicationController
  before_filter :authenticate, :except => [ :index ]
  before_filter :ensure_can_edit, :except => [ :index ]

  def index
    @cms_pages = CmsPage.all(:order => :id)
    @location  = @cms_pages
  end

  def new
    @cms_page = CmsPage.new(params[:cms_page])
    render :action => :edit
  end

  def edit
    @cms_page = CmsPage.find(params[:id])
  end

  def create
    @cms_page            = CmsPage.new(params[:cms_page])
    @cms_page.created_by = @user.id
    @cms_page.updated_by = @user.id
    if @cms_page.save
      redirect_to cms_page_path(@cms_page.slug)
    else
      render :action => :edit
    end
  end

  def update
    @cms_page                      = CmsPage.find(params[:id])
    params[:cms_page][:updated_by] = @user.id
    logger.debug params.inspect
    if @cms_page.update_attributes(params[:cms_page])
      redirect_to cms_page_path(@cms_page.slug)
    else
      render :action => :edit
    end
  end

  def destroy
    @cms_page = CmsPage.find(params[:id])
    @cms_page.deleted_by = @user.id
    @cms_page.deleted_at = Time.now
    @cms_page.save
    redirect_to admin_cms_pages_path
  end

  private

  def ensure_can_edit
    redirect_to admin_cms_pages_path unless CmsPage.can_edit?(@user)
  end

end