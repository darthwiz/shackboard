class LicenseController < ApplicationController
  before_filter :authenticate
  def confirm # {{{
    @file = FiledbFile.find(params[:id].to_i)
    unless (@file)
      redirect_to :back
    end
  end # }}}
end
