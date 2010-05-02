module WelcomeHelper

  def render_module(module_list, obj)
    case obj.class.to_s
    when 'Forum'
      render_module_forum(module_list, obj)
    end
  end

  def render_module_forum(module_list, forum)
    content_tag(:li, :class => 'module', :id => "module_#{module_list}_forum_#{forum.id}") do
      render :partial => '/welcome/module_forum', :locals => { :forum => forum }
    end
  end

  def link_to_forum_topic(topic)
    last_poster = topic.last_post(:user)
    time        = topic.last_post(:time)
    content_tag(:span, :class => 'topic', :id => domid(topic)) do
      [
        link_to(cleanup(topic.subject), topic, :class => 'title'),
        content_tag(:span, :class => 'last_post') do
          [
            content_tag(:span, "ultimo messaggio:", :class => 'label'),
            link_to(cleanup(last_poster.username), last_poster, :class => 'author'),
            link_to(post_time(time), topic_path(topic, :page => 'last', :anchor => 'last_post'), :class => 'time'),
          ].join("\n")
        end
      ].join("\n")
    end
  end

end
