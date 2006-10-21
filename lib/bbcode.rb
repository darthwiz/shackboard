class BBCode < String
  def to_html # {{{
    s = BBCode.new(self)
    s.gsub!(/&[^#]+/, "&amp;\1")
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
    s.gsub!(/\[quote\]/i, "<div class=\"quote\">")
    s.gsub!(/\[\/quote\]/i, "</div>")
    Smiley.all.each do |sm|
      s.gsub!(sm.code, " <img src=\"#{sm.url}\" alt=\"#{sm.code}\"> ")
    end
    return s
  end # }}}
end
