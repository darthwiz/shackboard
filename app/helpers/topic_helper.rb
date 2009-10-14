module TopicHelper

  def page_trail_topic(obj, opts={})
    trail   = []
    caption = obj.new_record? ? 'nuova discussione' : cleanup(obj.subject)
    trail  << [ caption, {} ]
    while(obj = obj.container)
      link = {}
      case obj.class.to_s
      when 'Forum'
        link = forum_path(obj)
      end
      trail << [ obj.name, link ] unless link.nil?
    end
    trail << [ "Forum", forum_root_path ]
    trail.reverse
  end

end
