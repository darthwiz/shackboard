class AdminController < ApplicationController
  layout 'forum'
  before_filter :authenticate

  def index
    @location   = :admin
    @page_title = "Amministrazione portale"
  end

end
