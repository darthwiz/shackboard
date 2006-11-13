class AnnouncementController < ApplicationController
  def index # {{{
    @ids = [6, 7, 9]
  end # }}}
  def view # {{{
    ids = [6, 7, 9]
    id  = ids[rand * ids.length]
    @announcement = Announcement.find(id)
    #render :partial => 'view'
  end # }}}
end
