class WelcomeController < ApplicationController

  def index 
    @page_title    = "StudentiBicocca.it - il portale degli studenti della Bicocca"
    @announcements = Announcement.find_latest(5)
  end 

end
