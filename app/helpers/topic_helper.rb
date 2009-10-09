module TopicHelper

  def page_trail_topic(obj, opts={})
    trail   = []
    caption = obj.new_record? ? 'nuova discussione' : cleanup(obj.subject)
    trail  << [ caption, {} ]
    while(obj = obj.container)
      link = {}
      case obj.class.to_s
      when 'Forum'
        if @legacy_mode == :old
          link = (obj.type == 'group') ? nil : "/portale/forum/forumdisplay.php?fid=#{obj.id}"
        else
          link = forum_path(obj)
        end
      end
      trail << [ obj.name, link ] unless link.nil?
    end
    trail.reverse
  end

end
