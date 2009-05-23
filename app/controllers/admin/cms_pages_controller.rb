class Admin::CmsPagesController < Admin::ApplicationController
  before_filter :authenticate, :except => [ :show, :index ]

  def index
    @cms_pages = CmsPage.all(:order => :id)
  end

  def show
  end

  def new
    @cms_page = CmsPage.new
  end

  def edit
    @cms_page = CmsPage.find(params[:id])
  end

  def create
  end

  def update
  end

  def destroy
  end

end
