module UsersHelper

  def editable_profile_field(user, field, options={})
    acl_edit = options[:can_edit] ? options[:can_edit]   : [ :adm, :self ]
    acl_see  = options[:can_see]  ? options[:can_see]    : [ :all ]
    type     = options[:type]     ? options[:type]       : :text_field
    label    = options[:label]    ? options[:label]      : field.to_s
    li_class = options[:class]    ? options[:class].to_s : field.to_s
    li_id    = "edit_user_#{field}"
    can_edit = @user.is_a?(User) && (acl_edit.include?(:adm) && @user.is_adm?) || (acl_edit.include?(:self) && @user == user)
    can_see  = acl_see.include?(:all) || can_edit || (acl_see.include?(:mod) && @user.is_a?(User) && @user.is_mod?) || (acl_see.include?(:self) && @user == user)
    return '' unless can_see
    begin
      value = options[:value] ? options[:value].to_s : cleanup(user.send(field.to_sym).to_s).gsub("\n", "<br />\n")
      value = '***' if type == :password_field
      label = link_to_remote(label, :url => edit_user_path(user, :field => field, :type => type), :method => :get) if can_edit
    rescue NoMethodError
      value = ''
    end
    content_tag(:li, :id => li_id, :class => li_class) do
      content_tag(:dl) do
        [ content_tag(:dt, label), content_tag(:dd, value) ].join(' ')
      end
    end
  end

  def profile_field_editor(user, field, options={})
    type     = options[:type]                 ? options[:type].to_sym : :text_field
    li_class = options[:class]                ? options[:class].to_s  : field.to_s
    choices  = options[:choices].is_a?(Array) ? options[:choices]     : user.choices_for(field)
    li_id    = "edit_user_#{field}"
    begin
      value = options[:value] ? options[:value].to_s : cleanup(user.send(field.to_sym).to_s).gsub("\n", "<br />\n")
    rescue NoMethodError
      value = ''
    end
    content_tag(:li, :id => li_id, :class => li_class) do
      capture do
        remote_form_for(user) do |f|
          concat "<dl>"
          concat content_tag(:dt, f.submit('salva'))
          if type == :password_field
            concat '<dd>'
            concat 'corrente: ' + password_field_tag('current_password') + '<br />'
            concat 'nuova: '    + password_field_tag('new_password')     + '<br />'
            concat 'conferma: ' + password_field_tag('confirm_password') + '<br />'
            concat '</dd>'
          elsif !choices.blank?
            concat content_tag(:dd, f.select(field.to_sym, choices.collect { |i| [ i, i ] }))
          else
            concat content_tag(:dd, f.send(type, field.to_sym))
          end
          concat "</dl>"
        end
      end
    end
  end

  def status_list(user=@user)
    statuses   = []
    mod_forums = user.moderates
    statuses << t(sexified(:Administrator, user.sex)) if user.is_adm?
    statuses << t(sexified(:SuperModerator, user.sex)) if (user.is_supermod? && !user.is_adm?)
    statuses << t(sexified(:Moderator, user.sex)) + ' di ' + mod_forums.collect { |i| link_to(cleanup(i.name), i) }.join(', ') unless mod_forums.empty?
    statuses << user.rank.title
    statuses.join(', ')
  end

  def page_trail_user(obj, opts={})
    trail  = []
    trail << [ "Profilo di #{cleanup(obj.username)}", {} ]
  end

end
