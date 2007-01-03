module ForumHelper
  def page_trail_Forum(loc) # {{{
    trail  = []
    trail << [ cleanup(loc.name), {} ]
    obj    = loc
    while(obj = obj.container)
      link = {}
      case obj.class.to_s
      when 'Forum'
	link[:controller] = 'forum'
	link[:action]     = 'view'
	link[:id]         = obj.id
      end
      trail << [ cleanup(obj.name), link ]
    end
    trail.reverse
  end # }}}
end
