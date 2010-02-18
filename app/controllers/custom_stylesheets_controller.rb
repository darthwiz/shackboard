class CustomStylesheetsController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :update_online, :set_stylesheet

  def show
    headers["Content-Type"] = 'text/css; charset = utf-8'
    @custom_stylesheet      = CustomStylesheet.find_by_obj_class_and_obj_id(params[:obj_class], params[:obj_id])
    if @custom_stylesheet.is_a?(CustomStylesheet)
      logger.debug "rendering #{@custom_stylesheet.inspect}"
      render :text => @custom_stylesheet.css
    else
      logger.debug "rendering nothing"
      render :nothing => true
    end
  end

end
