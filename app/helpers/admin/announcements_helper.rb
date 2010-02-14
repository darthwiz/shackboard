module Admin::AnnouncementsHelper

  def page_trail_admin_announcements(obj, opts={})
    [ [ "Amministrazione", admin_path ], [ "Annunci", nil ] ]
  end

  def page_trail_admin_announcement(obj, opts={})
    [
      [ "Amministrazione", admin_path ],
      [ "Annunci", admin_announcements_path ],
      obj.new_record? ? [ "nuovo annuncio", nil ] : [ cleanup(obj.title), nil ]
    ]
  end

end
