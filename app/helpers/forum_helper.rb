module ForumHelper

  def page_trail_forum(obj, opts={})
    trail    = []
    current  = cleanup(obj.name)
    current += content_tag(
      :span,
      " (moderato da #{obj.moderators.collect { |i| link_to(cleanup(i.username), i) }.join(', ')})",
      :class => 'moderators'
    ) unless obj.moderators.blank?
    trail << [ current, {} ]
    while(obj = obj.container)
      link = {}
      case obj.class.to_s
      when 'Forum'
        link = forum_path(obj)
      end
      trail << [ obj.name, link ]
    end
    trail << [ "Forum", forum_root_path ]
    trail.reverse
  end

  def page_trail_forums(obj, opts={})
    trail = [ [ "Forum", nil ] ]
  end

end
