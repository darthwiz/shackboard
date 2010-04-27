module SmileysHelper

  def editable_smiley(smiley)
    content_tag(:li, :class => 'smiley', :id => domid(smiley)) do
      content_tag(:dl) do
        [
          content_tag(:dt, :class => 'edit') do
            link_to_remote("modifica", :url => edit_smiley_path(smiley), :method => :get) if smiley.can_edit?(@user)
          end,
          content_tag(:dd, smiley.code, :class => 'code'),
          content_tag(:dd, smiley.url, :class => 'url'),
          content_tag(:dd, :class => 'image') do
            image_tag(smiley.url, :alt => smiley.code)
          end
        ].join(' ')
      end
    end
  end

  def smiley_editor(smiley)
    content_tag(:li, :class => 'smiley', :id => domid(smiley)) do
      capture do
        remote_form_for(smiley) do |f|
          concat "<dl>"
          concat content_tag(:dt, f.submit('salva'))
          concat content_tag(:dd, f.text_field(:code, :size => 10))
          concat content_tag(:dd, f.text_field(:url, :size => 80))
          concat content_tag(:dd, link_to_remote('elimina', :url => smiley_path(smiley), :method => :delete,
            :confirm => "Vuoi veramente cancellare questa faccina?"))
          concat "</dl>"
        end
      end
    end
  end

end
