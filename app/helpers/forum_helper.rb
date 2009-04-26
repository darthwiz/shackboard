module ForumHelper
  def page_trail_Forum(loc) # {{{
    trail  = []
    obj    = loc[1]
    trail << [ cleanup(obj.name), {} ]
    while(obj = obj.container)
      link = {}
      case obj.class.to_s
      when 'Forum'
        if @legacy_mode == :old
          forum_path(obj)
        else
          forum_path(obj)
        end
      end
      trail << [ obj.name, link ]
    end
    trail.reverse
  end # }}}
end
