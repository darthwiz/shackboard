module PostsHelper

  def page_trail_post(obj, opts={})
    topic = obj.topic
    trail = page_trail_topic(topic)
    trail.pop
    trail << [ cleanup(topic.title), topic ]
    trail << [ "messaggio #{obj.find_seq}", {} ]
  end

end
