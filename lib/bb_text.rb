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
    while s =~ /\[block=([^\]]*)\](.*?)\[\/block\]/im
      s.gsub!(/\[block=([^\]]*)\](.*?)\[\/block\]/im, "<div class=\"\\1\">\\2</div>")
    end
    while s =~ /\[span=([^\]]*)\](.*?)\[\/span\]/im
      s.gsub!(/\[span=([^\]]*)\](.*?)\[\/span\]/im, "<span class=\"\\1\">\\2</span>")
    end
    while s =~ /\[color=([^\]]*)\](.*?)\[\/color\]/im
      s.gsub!(/\[color=([^\]]*)\](.*?)\[\/color\]/im, "<span style=\"color: \\1;\">\\2</span>")
    end
    s.gsub!(/ -- /, ' &mdash; ')
    s.gsub!(/(^|[>[:space:]\n])([[:alnum:]]+):\/\/([^[:space:]]*)([[:alnum:]#?\/&=])([<[:space:]\n]|$)/, "\\1<a href=\"\\2://\\3\\4\" target=\"_blank\">\\2://\\3\\4</a>\\5")
    s.gsub!(/\[url=([^\]]*)\](.*?)\[\/url\]/, "<a href=\"\\1\" title=\"\\1\">\\2</a>")
    s.gsub!(/\[cms=([^\]]*)\](.*?)\[\/cms\]/) do |match| 
      if controller
        controller.link_to_cms_page($2, $1)
      else
        $2
      end
    end
    s.gsub!(/\[index ([^\]]*)\](.*?)\[\/index\]/) do |match| 
      params_string = $1
      title         = $2
      param_hash    = {}
      params_string.split(/\s+/).each do |pair|
        key, value             = pair.split('=', 2)
        param_hash[key.to_sym] = value
      end
      ret   = "<div class=\"index\"><span class=\"title\">#{title}</span>\n"
      pages = CmsPage.tagged_with(param_hash[:tags])
      unless pages.empty?
        ret += "<ul>\n"
        pages.each do |p|
          if controller
            ret += "<li>" + controller.link_to_cms_page(p.title, p.slug) + "</li>\n"
          else
            ret += "<li>" + p.title + "</li>\n"
          end
        end
        ret += "</ul>\n"
      end
      ret += "</div>"
    end
    s.gsub!(/\[youtube\]([^\[\]]+)\[\/youtube\]/i) do |match|
      url   = match.gsub(/^\[img\](.*)\[\/img\]/i, "\\1").strip
      video = url.gsub(/.*\?v=([A-Za-z0-9_-]+).*/, "\\1")
      html  = '<object type="application/x-shockwave-flash" ' +
        'style="width: 100%; height: 385px;" ' +
        'data="http://www.youtube.com/v/' + video + '">' +
        '<param name="movie" value="http://www.youtube.com/v/' +
        video + '" /></object>'
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
