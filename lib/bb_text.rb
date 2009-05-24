class BbText
  include ActionView::Helpers::TextHelper
  include ApplicationHelper
  def initialize(text='', smileys=[])
    @text    = text
    @smileys = smileys
  end

  def to_html(params={})
    require 'md5'
    s            = Sanitizer.sanitize_bb(@text)
    controller   = params[:controller]
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
    s.gsub!(/\[i\](.*?)\[\/i\]/im, "<i>\\1</i>")
    s.gsub!(/\[b\](.*?)\[\/b\]/im, "<b>\\1</b>")
    s.gsub!(/\[u\](.*?)\[\/u\]/im, "<u>\\1</u>")
    while s =~ /\[small\](.*?)\[\/small\]/im
      s.gsub!(/\[small\](.*?)\[\/small\]/im, "<small>\\1</small>")
    end
    while s =~ /\[big\](.*?)\[\/big\]/im
      s.gsub!(/\[big\](.*?)\[\/big\]/im, "<big>\\1</big>")
    end
    while s =~ /\[code\](.*?)\[\/code\]/im
      s.gsub!(/\[code\](.*?)\[\/code\]/im, "<div class=\"code\">\\1</div>")
    end
    while s =~ /\[quote\](.*?)\[\/quote\]/im
      s.gsub!(/\[quote\](.*?)\[\/quote\]/im, "<div class=\"quote\">\\1</div>")
    end
    while s =~ /\[spoiler\](.*?)\[\/spoiler\]/im
      s.gsub!(/\[spoiler\](.*?)\[\/spoiler\]/im) do |match|
        spoiler_id += 1
        dom_id = "spoiler_#{spoiler_base}_#{MD5.md5(match).to_s[0..4]}_#{spoiler_id}"
        "<div class=\"spoiler\">
          <a class=\"spoiler\" href=\"javascript:void(0);\" onclick=\"e = document.getElementById('#{dom_id}'); if (e.style.display == 'none') { e.style.display = ''} else { e.style.display = 'none' }\">spoiler</a>
          <div style=\"display: none;\" id=\"#{dom_id}\">
          #{$1}
          </div>
        </div>"; 
      end
    end
    s.gsub!(/--/, '&mdash;')
    s.gsub!(/(^|[>[:space:]\n])([[:alnum:]]+):\/\/([^[:space:]]*)([[:alnum:]#?\/&=])([<[:space:]\n]|$)/, "\\1<a href=\"\\2://\\3\\4\" target=\"_blank\">\\2://\\3\\4</a>\\5")
    s.gsub!(/\[url=([^\]]*)\](.*?)\[\/url\]/, "<a href=\"\\1\" title=\"\\1\">\\2</a>")
    s.gsub!(/\[color=([^\]]*)\](.*?)\[\/color\]/, "<span style=\"color: \\1;\">\\2</span>")
    s.gsub!(/\[cms=([^\]]*)\](.*?)\[\/cms\]/) do |match| 
      if controller
        controller.link_to_cms_page($2, $1)
      else
        $2
      end
    end
    @smileys.each do |sm|
      s.gsub!(/#{Regexp.escape(sm.code)}/, " <img src=\"#{sm.url}\" alt=\"\" /> ") unless sm.code.empty?
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
