class VotesController < ApplicationController
  skip_before_filter :load_defaults, :authenticate, :update_online,
    :set_stylesheet

  def vote
    render :nothing => true and return unless @user
    respond_to do |format|
      format.js do
        class_name     = params['type']
        id             = params['id'].to_i
        points         = params['points'].to_i
        points         = points == 0 ? 0 : points / points.abs
        @voting_object = Module.const_get(class_name).find(id)
        @voting_object.vote_with(@user, points)
        render :update do |page|
          page.replace "vote_#{class_name.underscore}_#{id}", :inline => "<%=button_for_voting(@voting_object)%>"
        end
      end
    end
  end

end
