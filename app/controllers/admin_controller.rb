class AdminController < ApplicationController
  layout 'forum'

  def index
    @location   = :admin
    @page_title = "Amministrazione portale"
  end

end
