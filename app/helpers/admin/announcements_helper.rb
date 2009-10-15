module Admin::AnnouncementsHelper

  def page_trail_admin_announcements(obj, opts={})
    [ [ "Amministrazione", admin_path ], [ "Annunci", nil ] ]
  end

  def page_trail_admin_announcement(obj, opts={})
    [
      [ "Amministrazione", admin_path ],
      [ "Annunci", admin_announcements_path ],
      [ cleanup(obj.title), nil ]
    ]
  end

end
