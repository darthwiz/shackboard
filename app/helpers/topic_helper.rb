module TopicHelper
  def page_trail_Topic(loc)
    trail  = []
    obj    = loc[1]
    trail << [ obj.subject, {} ]
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
