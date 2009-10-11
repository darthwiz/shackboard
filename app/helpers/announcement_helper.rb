module AnnouncementHelper

  def page_trail_announcement(obj, opts={})
    trail = [
      [ 'Annunci', announcements_path ],
      [ cleanup(obj.title), nil ]
    ]
  end

  def page_trail_announcements(obj, opts={})
    trail = [ [ 'Annunci', nil ] ]
  end

end

