module TagsHelper

  def editable_tags(obj)
    can_tag = obj.respond_to?(:can_tag?) && obj.can_tag?(@user)
    label   = can_tag ? link_to_remote('tags', :url => object_tag_edit_path(:type => obj.class.to_s, :id => obj.id)) + ':' : 'tags: '
    content_tag(:div, :class => 'editable_tags', :id => "tag_#{domid(obj)}") do
      [
        label,
        content_tag(:span, obj.tags.collect { |t| link_to_tag_search(t.tag) }.join(', '), :class => 'tag_list')
      ].join(' ')
    end
  end

  def tag_editor(obj)
    return unless obj.respond_to?(:can_tag?) && obj.can_tag?(@user)
    content_tag(:div, :class => 'tag_editor', :id => "tag_#{domid(obj)}") do
      form_remote_tag(:url => object_tag_set_path(:type => obj.class.to_s, :id => obj.id)) do
        [
          submit_tag('modifica', :class => 'submit'),
          text_field_tag(:tags, obj.tags_as_text, :class => 'text'),
        ].join(' ')
      end
    end
  end

  def link_to_tag_search(string_tag)
    link_to(string_tag, search_tags_path(:tags => string_tag), :class => "tag_#{string_tag}")
  end

end
