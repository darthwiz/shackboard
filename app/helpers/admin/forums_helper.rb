module Admin::ForumsHelper

  def page_trail_admin_forums(obj, opts={})
    [ [ "Amministrazione", admin_path ], [ "Forum", nil ] ]
  end

  def page_trail_admin_forum(obj, opts={})
    [
      [ "Amministrazione", admin_path ],
      [ "Forum", admin_forums_path ],
      [ cleanup(obj.name), nil ]
    ]
  end

end
