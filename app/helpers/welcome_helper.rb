module WelcomeHelper

  def render_module(module_list, obj)
    case obj.class.to_s
    when 'Forum'
      render_module_forum(module_list, obj)
    end
  end

  def render_module_forum(module_list, forum)
    content_tag(:li, :id => "module_#{module_list}_forum_#{forum.id}") do
      link_to(cleanup(forum.name), forum)
    end
  end

end
