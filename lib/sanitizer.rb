class Sanitizer
  def self.sanitize_html(html, ok_tags=nil)
    # Adapted from http://ideoplex.com/id/1138/sanitize-html-in-ruby
    # Adapted from http://snippets.dzone.com/posts/show/3822

    ok_tags = 'a href, b, br, p, i, em, div, span, ul, li, img src alt, h1, h2, h3, h4, h5' unless ok_tags
    # no closing tag necessary for these
    solo_tags = [ 'br','hr', 'img' ]

    # Build hash of allowed tags with allowed attributes
    tags    = ok_tags.downcase.split(',').collect!{ |s| s.split(' ') }
    allowed = {}
    tags.each do |s|
      key           = s.shift
      allowed[key]  = s
      allowed[key] << 'style'
      allowed[key] << 'class'
    end

    # Analyze all <> elements
    stack  = Array.new
    result = html.gsub( /(<.*?>)/m ) do |element|
      if element =~ /\A<\/(\w+)/ then
        # </tag>
        tag = $1.downcase
        if allowed.include?(tag) && stack.include?(tag) then
          # If allowed and on the stack
          # Then pop down the stack
          top = stack.pop
          out = "</#{top}>"
          until top == tag do
            top = stack.pop
            out << "</#{top}>"
          end
          out
        end
      elsif element =~ /\A<(\w+)\s*\/>/
        # <tag />
        tag = $1.downcase
        if allowed.include?(tag) then
          "<#{tag} />"
        end
      elsif element =~ /\A<(\w+)/ then
        # <tag ...>
        tag = $1.downcase
        if allowed.include?(tag) then
          if ! solo_tags.include?(tag) then
            stack.push(tag)
          end
          if allowed[tag].length == 0 then
            # no allowed attributes
            "<#{tag}>"
          else
            # allowed attributes?
            out = "<#{tag}"
            while ($' =~ /(\w+)=("[^"]+")/)
              attr = $1.downcase
              valu = $2
              if allowed[tag].include?(attr) then
                out << " #{attr}=#{valu}"
              end
            end
            out << ">"
          end
        end
      end
    end

    # eat up unmatched leading >
    while result.sub!(/\A([^<]*)>/m) { $1 } do end

    # eat up unmatched trailing <
    while result.sub!(/<([^>]*)\Z/m) { $1 } do end

    # clean up the stack
    if stack.length > 0 then
      result << "</#{stack.reverse.join('></')}>"
    end

    result
  end

  def self.sanitize_bb(text)
    ok_tags   = 'u, i, b, img, quote, list, color, size'
    solo_tags = [ '*' ]

    # Build hash of allowed tags with allowed attributes
    tags    = ok_tags.downcase().split(',').collect!{ |s| s.split(' ') }
    allowed = Hash.new
    tags.each do |s|
      key          = s.shift
      allowed[key] = s
    end

    # Analyze all [] elements
    stack  = Array.new
    result = text.gsub( /(\[.*?\])/m ) do |element|
      if element =~ /\A\[\/(\w+)/ then
        # [/tag]
        tag = $1.downcase
        if allowed.include?(tag) && stack.include?(tag) then
          # If allowed and on the stack
          # Then pop down the stack
          top = stack.pop
          out = "[/#{top}]"
          until top == tag do
            top = stack.pop
            out << "[/#{top}]"
          end
          out
        end
      elsif element =~ /\A\[(\w+)/ then
        # [tag ...]
        tag = $1.downcase
        if allowed.include?(tag) then
          if ! solo_tags.include?(tag) then
            stack.push(tag)
          end
        end
        "#{element}"
      else
        "#{element}"
      end
    end

    # clean up the stack
    if stack.length > 0 then
      result << "[/#{stack.reverse.join('][/')}]"
    end

    result
  end
end
