module PostsHelper

  def page_trail_post(obj, opts={})
    topic = obj.topic
    trail = page_trail_topic(topic)
    trail.pop
    trail << [ cleanup(topic.title), topic ]
    if obj.new_record?
      trail << [ "nuovo messaggio", nil ]
    else
      trail << [ "messaggio #{obj.find_seq}", nil ]
    end
  end

  def page_trail_report_post(obj, opts={})
    trail = page_trail_post(obj, opts)
    trail.pop
    trail << [ "segnalazione messaggio", {} ]
  end

  def link_to_post_with_topic_and_date(post)
    s  = link_to(cleanup(post.user.username), post.user)
    s << ' in '
    s << link_to(cleanup(post.topic.title), post.topic)
    s << ' il '
    s << link_to(post.created_at.strftime("%d/%m/%Y, %H.%M"), post)
  end

end
