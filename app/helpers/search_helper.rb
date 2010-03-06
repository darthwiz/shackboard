module SearchHelper

  def link_to_result(obj)
    case obj.class.to_s
    when 'Topic'
      link_to([
        content_tag(:span, cleanup(obj.subject), :class => 'title'),
        'nel forum',
        content_tag(:span, cleanup(obj.forum.name), :class => 'forum'),
      ].join(' '), obj)
    when 'Post'
      link_to([
        content_tag(:span, cleanup(obj.user.username), :class => 'user'),
        'in',
        content_tag(:span, cleanup(obj.topic.subject), :class => 'topic'),
        'il',
        content_tag(:span, Time.at(obj.dateline).strftime("%d/%m/%Y, %H.%M"), :class => 'date'),
      ].join(' '), obj)
    end
  end

end
