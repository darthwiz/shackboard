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

  def link_to_popular_topic(t)
    content_tag(:span, [
      link_to(cleanup(t.subject), t),
      '(',
      content_tag(:span, [
        content_tag(:span, 'non mi piace:', :class => 'label'),
        content_tag(:span, t.dislikes, :class => 'votes'),
      ].join(' '), :class => 'dislike'),
      '/',
      content_tag(:span, [
        content_tag(:span, 'mi piace:', :class => 'label'),
        content_tag(:span, t.likes, :class => 'votes'),
      ].join(' '), :class => 'like'),
      ')',
    ].join(' '), :class => 'ratings')
  end

end
