class BbText
  def initialize(text='')
    @text = text
  end

  def to_html(params={})
    s            = Sanitizer.sanitize_bb(@text)
    user         = params[:user]
    spoiler_base = params[:spoiler_id].to_i
    spoiler_id   = 0
    s.gsub!(/&([^#]+)/, "&amp;\\1")
    s.gsub!(/>/, "&gt;")
    s.gsub!(/</, "&lt;")
    s.gsub!(/\n/, "<br/>\n")
    s.gsub!(/\[img\]([^\[\]]+)\[\/img\]/i) do |match|
      match.gsub!(/^\[img\](.*)\[\/img\]/i, "\\1")
      match.strip!
      " <img src=\"#{match}\" alt=\"(img)\"/> "
    end
    s.gsub!(/\[i\]/i, "<i>")
    s.gsub!(/\[\/i\]/i, "</i>")
    s.gsub!(/\[b\]/i, "<b>")
    s.gsub!(/\[\/b\]/i, "</b>")
    s.gsub!(/\[u\]/i, "<u>")
    s.gsub!(/\[\/u\]/i, "</u>")
    s.gsub!(/\[code\]/i, "<div class=\"code\">")
    s.gsub!(/\[\/code\]/i, "</div>")
    s.gsub!(/\[quote\]/i, "<div class=\"quote\">")
    s.gsub!(/\[\/quote\]/i, "</div>")
    s.gsub!(/\[spoiler\]/i) do |match|
      spoiler_id += 1
      dom_id = "spoiler_#{spoiler_base}_#{spoiler_id}"
      "<div class=\"spoiler\">
        <a class=\"spoiler\" href=\"javascript:void(0);\" onclick=\"e = document.getElementById('#{dom_id}'); if (e.style.display == 'none') { e.style.display = ''} else { e.style.display = 'none' }\">spoiler</a>
        <div style=\"display: none;\" id=\"#{dom_id}\">"; 
    end
    s.gsub!(/\[\/spoiler\]/i, "</div></div>")
    s.gsub!(/(^|[>[:space:]\n])([[:alnum:]]+):\/\/([^[:space:]]*)([[:alnum:]#?\/&=])([<[:space:]\n]|$)/, "\\1<a href=\"\\2://\\3\\4\" target=\"_blank\">\\2://\\3\\4</a>\\5")
    Smiley.all.each do |sm|
      s.gsub!(sm.code, " <img src=\"#{sm.url}\" alt=\"#{sm.code}\" /> ")
    end
    if user.is_a? User
      Smiley.find_all_by_user_id(user.id).each do |sm|
        s.gsub!(sm.code, " <img src=\"#{sm.url}\" alt=\"#{sm.code}\" /> ")
      end
    end
    return s
  end

end
