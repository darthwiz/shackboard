class Admin::CustomStylesheetsController < Admin::ApplicationController
  before_filter :authenticate
  layout 'forum'

  def create
    @custom_stylesheet = CustomStylesheet.new(params[:custom_stylesheet])
    @custom_stylesheet.save!
    redirect_to :back
  end

  def update
    @custom_stylesheet = CustomStylesheet.find_by_stylable_type_and_stylable_id(params[:custom_stylesheet][:stylable_type], params[:custom_stylesheet][:stylable_id])
    @custom_stylesheet.update_attributes(params[:custom_stylesheet])
    redirect_to :back
  end

end
