class SmileyController < ApplicationController
  def view
    uid      = @user.id if @user
    uid      = params[:id] ? params[:id] : uid
    uid      = uid.to_i # could be zero
    conds    = [ 'type = ? AND (user_id = 0 OR user_id = ?)', 'smiley', uid ]
    order    = 'user_id DESC, id'
    @smileys = Smiley.find(:all, :conditions => conds, :order => order)
  end
end
