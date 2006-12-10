# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActionView::Helpers::UrlHelper
  def is_adm?(user=@user) # {{{
    Group.include?(FILEDB_ADM_GROUP, user)
  end # }}}
  def icon_selector(object, method, icon=nil) # {{{
    s = "<select id='#{object}_#{method}' name='#{object}[#{method}]'>\n"
    FILEDB_ICONS[1].each do |i|
      s << "  <option value='#{i[1]}'"
      s << " selected" if icon == i[1]
      s << ">#{i[0]}</option>\n"
    end
    s << "</select>\n"
  end # }}}
  def icon(filename) # {{{
    caption = nil
    FILEDB_ICONS[1].each do |i|
      caption = i[0] if filename == i[1]
    end
    filename = '' unless caption
    "<img src='#{FILEDB_ICONS[0]}#{filename}' alt='#{caption}'/>"
  end # }}}
end
