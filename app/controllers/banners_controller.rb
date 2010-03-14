class BannersController < ApplicationController
  skip_before_filter :recognize_user, :load_defaults, :authenticate, :update_online, :set_stylesheet

  def show
    respond_to do |format|
      format.js do
        render :inline => "<%=link_to_random_banner%>"
      end
    end
  end

end
