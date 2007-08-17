module TopicHelper
  def page_trail_Topic(loc) # {{{
    trail  = []
    obj    = loc[1]
    trail << [ obj.subject, {} ]
    while(obj = obj.container)
      link = {}
      case obj.class.to_s
      when 'Forum'
	link[:controller] = 'forum'
	link[:action]     = 'view'
	link[:id]         = obj.id
      end
      trail << [ h(strip_tags(obj.name)), link ]
    end
    trail.reverse
  end # }}}
end
