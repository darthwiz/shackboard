class CmsPagesController < ApplicationController

  def show
    @cms_page   = CmsPage.find_by_slug(params[:slug])
    @page_title = @cms_page.title
    @location   = @cms_page
  end

end
