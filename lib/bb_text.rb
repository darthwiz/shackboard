class BbText
  include ActionView::Helpers::TextHelper
  def initialize(text='', smileys=[])
    @text    = text
    @smileys = smileys
  end

  def to_html(params={})
    s            = Sanitizer.sanitize_bb(@text)
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
    s.gsub!(/\[url=([^\]]*)\](.*)\[\/url\]/, "<a href=\"\\1\" title=\"\\1\">\\2</a>")
    @smileys.each do |sm|
      s.gsub!(sm.code, " <img src=\"#{sm.url}\" alt=\"#{sm.code}\" /> ") unless sm.code.empty?
    end
    return s
  end

  def to_plaintext(params={})
    s = Sanitizer.sanitize_bb(@text)
    s.gsub!(/\[img\]([^\[\]]+)\[\/img\]/i, '[immagine]')
    s.gsub!(/\[i\]/i, '')
    s.gsub!(/\[\/i\]/i, '')
    s.gsub!(/\[b\]/i, '')
    s.gsub!(/\[\/b\]/i, '')
    s.gsub!(/\[u\]/i, '')
    s.gsub!(/\[\/u\]/i, '')
    s.gsub!(/\[code\]/i, '')
    s.gsub!(/\[\/code\]/i, '')
    s.gsub!(/\[quote\]/i, '')
    s.gsub!(/\[\/quote\]/i, '')
    s.gsub!(/\[spoiler\]/i, '')
    s.gsub!(/\[\/spoiler\]/i, '')
    s = word_wrap(s, :line_width => 80)
    return s
  end

end