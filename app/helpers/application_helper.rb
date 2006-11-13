# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActionView::Helpers::UrlHelper
  def utf8(string) # {{{
    Iconv.new('utf-8', 'iso-8859-1').iconv(string)
  end # }}}
  def iso(string) # {{{
    Iconv.new('iso-8859-1', 'utf-8').iconv(string)
  end # }}}
  def lookup(what, opts = {}) # {{{
    if (!@helper_lut) then
      @helper_lut = {
        :user => {},
        :rank => [],
      }
    end
    case what
    when :user
      return lookup_user(opts)
    when :rank
      return lookup_rank(opts)
    end
  end # }}}
  def dimmer(color, pct) # {{{
    if (color =~ /#[0-9a-fA-F]{6}/) then
      r = (color[1,2].hex) * pct / 100.0
      g = (color[3,2].hex) * pct / 100.0
      b = (color[5,2].hex) * pct / 100.0
    else
      r = 128
      g = 128
      b = 128
    end
    return sprintf("#%02x%02x%02x", r.to_i, g.to_i, b.to_i)
  end # }}}
  def page_seq(opts = {}) # {{{
    # shortcut variables {{{
    first  = opts[:first]
    last   = opts[:last] || first
    cur    = opts[:current]
    ipp    = opts[:ipp]               # items per page
    extra  = opts[:extra_links] || [] # [:first, :back, :forward, :last]
    ctrl   = opts[:controller]
    actn   = opts[:action]
    id     = opts[:id]
    hclass = opts[:classes]  || { :normal => nil, :current => 'current_page' }
    adj    = opts[:adjacent] || 1
    label  = { :first   => '<< inizio', :back => '< indietro',
               :forward => 'avanti >',  :last => 'fine >>' }
    pages  = []
    s      = ""
    # first, current and last are items and not pages if ipp is present
    # so we convert them to pages
    if (ipp) then
      first = ((first - 1)/ ipp) + 1
      last  = ((last - 1)/ ipp) + 1
      cur   = ((cur - 1)/ ipp) + 1 if cur
    end
    # }}}
    # adjacent pages {{{
    for i in 0..adj do
      p  = []
      p << first + i
      p << cur - i if cur
      p << cur + i if cur
      p << last - i
      p.each do |j|
        pages << j if (j > 0 && j <= last)
      end
    end
    # }}}
    ctrl_opts = { :controller => ctrl, :action => actn, :id => id }
    # first and back links {{{
    if (cur)
      if (cur > first) then
        if (extra.include? :first) then
          if (ipp) then
            ctrl_opts[:start] = (first - 1) * ipp + 1
          else
            ctrl_opts[:page] = first
          end
          s << link_to(label[:first], ctrl_opts) + "\n"
        end
        if (extra.include? :back) then
          if (ipp) then
            ctrl_opts[:start] = (cur - 2) * ipp + 1
          else
            ctrl_opts[:page] = cur - 1
          end
          s << link_to(label[:back], ctrl_opts) + "\n"
        end
      end
    else
      if (extra.include? :first) then
        if (ipp) then
          ctrl_opts[:start] = (first - 1) * ipp + 1
        else
          ctrl_opts[:page] = first
        end
        s << link_to(label[:first], ctrl_opts) + "\n"
      end
    end
    # }}}
    # numbered pages loop {{{
    prev = first
    pages.sort.uniq.each do |p|
      if (p > prev + 1) then
        if (ipp) then
          ctrl_opts[:start] = (prev + p) / 2 * ipp + 1
        else
          ctrl_opts[:page] = (prev + p) / 2 + 1
        end
        s << link_to('...', ctrl_opts) + "\n"
      end
      if (cur) then
        if (p == cur) then
          s << p.to_s + "\n"
        else
          if (ipp) then
            ctrl_opts[:start] = (p - 1) * ipp + 1
          else
            ctrl_opts[:page] = p
          end
          s << link_to(p, ctrl_opts) + "\n"
        end
      else
        if (ipp) then
          ctrl_opts[:start] = (p - 1) * ipp + 1
        else
          ctrl_opts[:page] = p
        end
        s << link_to(p, ctrl_opts) + "\n"
      end
      prev = p
    end
    # }}}
    # forward and last links {{{
    if (cur)
      if (cur < last) then
        if (extra.include? :forward) then
          if (ipp) then
            ctrl_opts[:start] = cur * ipp + 1
          else
            ctrl_opts[:page] = cur + 1
          end
          s << link_to(label[:forward], ctrl_opts) + "\n"
        end
        if (extra.include? :last) then
          if (ipp) then
            ctrl_opts[:start] = (last - 1) * ipp + 1
          else
            ctrl_opts[:page] = last
          end
          s << link_to(label[:last], ctrl_opts) + "\n"
        end
      end
    else
      if (extra.include? :last) then
        if (ipp) then
          ctrl_opts[:start] = (last - 1) * ipp + 1
        else
          ctrl_opts[:page] = last
        end
        s << link_to(label[:last], ctrl_opts) + "\n"
      end
    end
    # }}}
    return '' if (cur && cur == first && cur == last)
    return s
  end # }}}
  def bb_to_html(s) # {{{
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
    s.gsub!(/\[quote\]/i, "<div class=\"post_quote\">")
    s.gsub!(/\[\/quote\]/i, "</div>")
    Smiley.all.each do |sm|
      s.gsub!(sm.code, " <img src=\"#{sm.url}\" alt=\"#{sm.code}\"> ")
    end
    return s
  end # }}}
  def timestamp_to_date(ts) # {{{
    date = Time.at(ts).strftime("%d/%m/%Y")
    time = Time.at(ts).strftime("%H.%M")
    "#{date}, #{time}"
  end # }}}
def collection_select_with_selected(object, method, collection, value_method, text_method, current_value=nil) # {{{
  result = "<select name='#{object}[#{method}]'>\n" 
  for element in collection
    if current_value.to_s == element.send(value_method).to_s
      result << "<option value='#{element.send(value_method)}' selected='selected'>#{element.send(text_method)}</option>\n" 
    else
      result << "<option value='#{element.send(value_method)}'>#{element.send(text_method)}</option>\n" 
    end
  end
  result << "</select>\n" 
  return result
end # }}}
def button_to_remote(name, options = {}, html_options = {})  # {{{
  button_to_function(name, remote_function(options), html_options)
end # }}}
  private
  def lookup_user(opts) # {{{
    if (username = opts[:username]) then
      if (u = @helper_lut[:user][username]) then
        return u
      else
        u = User.find_by_username(username)
        @helper_lut[:user][username] = u
        return u
      end
    end
  end # }}}
  def lookup_rank(opts) # {{{
    user  = opts[:user]
    ranks = @helper_lut[:rank]
    now   = Time.now.to_i
    if (ranks.empty?) then
      ranks    = Rank.find(:all, :order => 'posts')
      maxposts = User.maximum(:postnum)
      ranksnum = ranks.length
      for i in 0..(ranksnum - 1)
        ranks[i].freakfactor = maxposts.to_f / 4**(ranksnum-i)
      end
    end
    rank = ranks[0]
    if (user)
      ranks.each do |r|
        rank = r if user.postnum > r.freakfactor
      end
    end
    return rank
  end # }}}
end
