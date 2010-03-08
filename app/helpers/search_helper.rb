module SearchHelper

  def link_to_result(obj)
    case obj.class.to_s
    when 'Topic'
      tags = obj.tags
      if obj.tags.blank? 
        tag_links = ''
      else
        tag_links = content_tag(:span, '(' + obj.tags.collect { |t| link_to_tag_search(t.tag) }.join(', ') + ')', :class => 'tags')
      end
      content_tag(:span, [
        link_to(cleanup(obj.subject), obj, :class => 'topic'),
        'nel forum',
        link_to(cleanup(obj.forum.name), obj.forum, :class => 'forum'),
        tag_links
      ].join(' '), :class => 'result_topic')
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
=begin
      link_to([
        content_tag(:span, cleanup(obj.subject), :class => 'title'),
        'nel forum',
        content_tag(:span, cleanup(obj.forum.name), :class => 'forum'),
      ].join(' '), obj)
=end
