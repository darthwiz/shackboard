class TriviaController < ApplicationController
  layout 'forum'

  def index
    @latest_users       = User.find(:all, :order => 'regdate DESC', :limit => 5)
    @top_spammers_today = Post.top_spammers(5, 1.day.ago).collect { |i| i.user }
    @top_spammers_month = Post.top_spammers(5, 1.month.ago).collect { |i| i.user }
    @top_spammers_ever  = User.find(:all, :order => 'postnum DESC', :limit => 5)
  end

end
