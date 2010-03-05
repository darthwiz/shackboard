module TagsHelper

  def editable_tags(obj)
    return unless @user
    content_tag(:div, :class => 'editable_tags', :id => "tag_#{domid(obj)}") do
      [ 
        link_to_remote('tags', :url => object_tag_edit_path(:type => obj.class.to_s, :id => obj.id)) + ':',
        content_tag(:span, obj.tags.collect(&:tag).join(', '), :class => 'tag_list')
      ].join(' ')
    end
  end

  def tag_editor(obj)
    return unless @user
    content_tag(:div, :class => 'tag_editor', :id => "tag_#{domid(obj)}") do
      form_remote_tag(:url => object_tag_set_path(:type => obj.class.to_s, :id => obj.id)) do
        [
          submit_tag('modifica', :class => 'submit'),
          text_field_tag(:tags, obj.tags_as_text, :class => 'text'),
        ].join(' ')
      end
    end
  end

end
