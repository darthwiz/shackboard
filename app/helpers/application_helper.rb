# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActionView::Helpers::UrlHelper
  include TopicHelper
  include ForumHelper

  def utf8(string)
    Iconv.new('utf-8', 'iso-8859-1').iconv(string)
  end

  def iso(string)
    Iconv.new('iso-8859-1', 'utf-8').iconv(string)
  end

  def dimmer(color, pct)
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
  end

  def domid(obj)
    begin
      obj = obj.actual if obj.respond_to?(:actual)
      obj.class.to_s.underscore + "_" + obj.id.to_s
    rescue
      # do nothing XXX ugly hack to prevent errors in case of a dangling link
    end
  end

  def slugify(s, length=80)
    s = word_wrap(s.to_s, :line_width => length).split("\n").first.to_s
    s.gsub(/[^[:alnum:]]/, '-').gsub(/-+/, '-').downcase.gsub(/(^-|-$)/, '')
  end

  def cleanup(str)
    h(strip_tags(str))
  end

  def icon(t)
    icon = ""
    case t
    when :folder
      icon = image_tag("http://www.studentibicocca.it/portale/forum/images/folder.gif")
    end
    icon
  end

  def link_user_edit
    return nil unless @user.is_a? User
    msg = 'impostazioni'
    if @legacy_mode == :old
      s = link_to msg, '/portale/forum/usercp.php'
    else
      link             = { :controller => 'user', :action => 'edit' }
      link[:host]      = @host_forum if @host_forum
      link[:only_path] = false if @host_forum
      s                = link_to msg, link
    end
    content_tag('span', s, :class => 'profile')
  end

  def link_user_register
    msg = 'nuovo utente'
    s = link_to msg, new_user_path(:rules => true)
    content_tag('div', s, :class => 'user_register')
  end

  def link_logout
    msg              = 'logout'
    link             = { :controller => 'login', :action => 'logout' }
    link[:host]      = @host_forum if @host_forum
    link[:only_path] = false if @host_forum
    s                = link_to msg, link
    content_tag('span', s, :class => 'logout')
  end

  def link_draft_list
    link_to_unless_current 'bozze', {:controller => 'draft', :action => 'list'},
      {:class => 'draft_list'}
  end

  def link_post_edit(post, user)
    caption = 'modifica'
    only    = 'only_mod'
    only   += " only_user_#{post.user.id}" if user.is_a? User
    l = link_to caption,
      { :controller => 'post', :action => 'edit', :id => post }
    content_tag('span', l, :class => "button post_edit #{only}",
      :style => 'display: none;')
  end

  def link_post_new(ctx=@topic, params={})
    quote   = params[:quote] ? true : false
    ctx     = ctx.actual if ctx.respond_to?(:actual)
    caption = 'nuova&nbsp;risposta'
    case ctx.class.to_s
    when 'Topic'
      l = link_to caption,
        { :controller => 'post', :action => 'new', :class => 'topic',
          :reply => ctx.id, :quote => quote }
    when 'Post'
      l = link_to caption,
        { :controller => 'post', :action => 'new', :class => 'post',
          :reply => ctx.id, :quote => true }
    end
    content_tag('span', l, :class => 'button post_new')
  end

  def link_to_cms_page(text, slug, user=@user)
    page = CmsPage.find_by_slug(slug)
    if page
      html = link_to(text, cms_page_path(slug), :title => page.title)
    else
      html = text
      html = link_to(
        text,
        new_admin_cms_page_path(page, :cms_page => { :slug => slug }),
        :class => 'inexistent'
      ) if CmsPage.can_edit?(user)
    end
    html
  end

  def link_topic_new(ctx=@forum)
    raise TypeError unless ctx.is_a? Forum
    l = link_to 'nuova discussione',
      { :controller => 'topic', :action => 'new', :id => ctx }
    content_tag('span', l, :class => 'button topic_new')
  end

  def link_pm_new(ctx=nil)
    ctx = ctx.actual if ctx.respond_to?(:actual)
    case ctx.class.to_s
    when 'Post'
      l = link_to 'rispondi in privato',
        { :controller => :pms, :action => 'new', :class => 'post',
          :reply => ctx.id }
    when 'Topic'
      l = link_to 'rispondi in privato',
        { :controller => :pms, :action => 'new', :class => 'topic',
          :reply => ctx.id }
    when 'Pm'
      l = link_to 'rispondi',
        { :controller => :pms, :action => 'new', :class => 'pm',
          :reply => ctx.id }
    else
      l = link_to 'nuovo messaggio privato',
        {:controller => :pms, :action => 'new'}
    end
    content_tag('span', l, :class => 'button pm_new')
  end

  def link_pm_list
    return nil unless @user.is_a? User
    msg  = 'messaggi privati'
    link = { :controller => :pms, :action => :index }
    s    = link_to msg, link
    content_tag('span', s, :class => 'pm_list')
  end

  def link_pm_trash
    link_to 'cestino', {:controller => :pm, :action => :index,
      :folder => 'trash'}, {:class => 'pm_trash'}
  end

  def link_pm_unread(user=@user)
    count = Pm.unread_for(user)
    msg   = "Hai un messaggio privato non letto."        if count == 1
    msg   = "Hai #{count} messaggi privati non letti."   if count > 1
    link  = pms_path
    msg ? link_to(msg, link) : nil
  end

  def link_blogs_unread(user=@user)
    return nil unless user.is_a? User
    count = BlogPost.count_unread_for(user)
    msg   = "Hai un commento non letto nei tuoi blog."       if count == 1
    msg   = "Hai #{count} commenti non letti nei tuoi blog." if count > 1
    link  = { 
      :controller => 'blog',
      :action     => 'list',
      :username   => user.username
    }
    link[:host]      = @host_forum if @host_forum
    link[:only_path] = false if @host_forum
    msg ? link_to(msg, link) : nil
  end

  def link_draft_unsent(user=@user)
    count = Draft.unsent_for(user)
    msg   = "Hai una bozza non inviata."      if count == 1
    msg   = "Hai #{count} bozze non inviate." if count > 1
    link  = drafts_path
    msg ? link_to(msg, link) : nil
  end

  def link_file_unapproved(user=@user)
    return nil unless is_file_adm?(user)
    n    = FiledbFile.count_unapproved
    msg  = "C'è un nuovo file in attesa di approvazione."       if n == 1
    msg  = "Ci sono #{n} nuovi file in attesa di approvazione." if n > 1
    link = { :controller => 'file', :action => 'review' }
    link[:host]      = @host_filedb if @host_filedb
    link[:only_path] = false if @host_filedb
    msg ? link_to(msg, link) : nil
  end

  def link_file_upload
    link_to 'carica un nuovo file', :action => 'upload' \
      unless @location == [ 'File', :upload ]
  end

  def page_trail(loc=@location, opts={})
    s = link_to('Portale', root_path)
    case loc.class.to_s
    when 'Array'
      method_name = ('page_trail_' + loc.first.class.to_s.underscore.pluralize).to_sym
    else
      method_name = ('page_trail_' + loc.class.to_s.underscore).to_sym
    end
    if ENV['RAILS_ENV'] == 'development'
      logger.info "** breadcrumb helper: calling #{method_name}"
    end
    trail = nil
    trail = self.send(method_name, loc, opts) if self.respond_to?(method_name)
    s    += ' &gt; ' + trail.collect { |i|
      if i[1].blank?
        content_tag('span', cleanup(i[0]), :class => 'current_location')
      else
        link_to(cleanup(i[0]), i[1])
      end
    }.join(' &gt; ') if trail.is_a? Array
    content_tag('span', s, :class => 'page_trail')
  end

  def page_seq(opts=@page_seq_opts)
    return unless opts.is_a? Hash
    # shortcut variables
    first  = opts[:first] || 1
    last   = opts[:last]  || first
    cur    = opts[:current]
    ipp    = opts[:ipp]               # items per page
    extral = opts[:extra_links] || [] # [:first, :back, :forward, :last]
    getp   = opts[:get_parms]   || [] # extra parameters copied from GET method
    extrap = opts[:extra_parms] || {}
    ctrl   = opts[:controller]  || params[:controller]
    actn   = opts[:action]      || params[:action]
    id     = opts[:id]          || params[:id]
    adj    = opts[:adjacent]    || 1
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

    # adjacent pages
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

    ctrl_opts = { :controller => ctrl, :action => actn, :id => id }
    getp.each { |pname| ctrl_opts[pname] = params[pname] }
    extrap.each_pair { |key, value| ctrl_opts[key] = value }
    # first and back links
    if (cur)
      if (cur > first) then
        if (extral.include? :first) then
          if (ipp) then
            ctrl_opts[:start] = (first - 1) * ipp + 1
          else
            ctrl_opts[:page] = first
          end
          s << link_to(label[:first], ctrl_opts) + "\n"
        end
        if (extral.include? :back) then
          if (ipp) then
            ctrl_opts[:start] = (cur - 2) * ipp + 1
          else
            ctrl_opts[:page] = cur - 1
          end
          s << link_to(label[:back], ctrl_opts) + "\n"
        end
      end
    else
      if (extral.include? :first) then
        if (ipp) then
          ctrl_opts[:start] = (first - 1) * ipp + 1
        else
          ctrl_opts[:page] = first
        end
        s << link_to(label[:first], ctrl_opts) + "\n"
      end
    end

    # numbered pages loop
    prev = first
    pages.sort.uniq.each do |p|
      if (p > prev + 1) then
        if (ipp) then
          ctrl_opts[:start] = ((prev + p) / 2 - 1) * ipp + 1
        else
          ctrl_opts[:page] = ((prev + p) / 2 -1 ) + 1
        end
        s << link_to('...', ctrl_opts) + "\n"
      end
      if (cur) then
        if (p == cur) then
          s << content_tag('span', p, :class => 'current') + "\n"
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

    # forward and last links
    if (cur)
      if (cur < last) then
        if (extral.include? :forward) then
          if (ipp) then
            ctrl_opts[:start] = cur * ipp + 1
          else
            ctrl_opts[:page] = cur + 1
          end
          s << link_to(label[:forward], ctrl_opts) + "\n"
        end
        if (extral.include? :last) then
          if (ipp) then
            ctrl_opts[:start] = (last - 1) * ipp + 1
          else
            ctrl_opts[:page] = last
          end
          s << link_to(label[:last], ctrl_opts) + "\n"
        end
      end
    else
      if (extral.include? :last) then
        if (ipp) then
          ctrl_opts[:start] = (last - 1) * ipp + 1
        else
          ctrl_opts[:page] = last
        end
        s << link_to(label[:last], ctrl_opts) + "\n"
      end
    end

    return '' if (cur && cur == first && cur == last)
    content_tag('span', s, :class => 'page_seq')
  end

  def text_to_html(text, format=:bb, smileys=[])
    text   = String.new(text.to_s)
    format = format.to_sym
    case format
    when :bb
      return bb_to_html(text, smileys)
    when :textile
      return textilize(text)
    when :html
      return text
    else
    end
  end

  def bb_to_html(s, smileys=[])
    BbText.new(s, smileys).to_html(:spoiler_id => rand(10000))
  end

  def post_time(time)
    now = Time.now
    if    time < now - 1.year then return time.strftime('%d/%m/%y')
    elsif time < now - 1.day  then return time.strftime('%d/%m')
    else                           return time.strftime('%H.%M')
    end
  end

  def timestamp_to_date(ts)
    date = Time.at(ts).strftime("%d/%m/%Y")
    time = Time.at(ts).strftime("%H.%M")
    "#{date}, #{time}"
  end

  def timestamp_to_time(ts, opts={})
    string  = "%H.%M"
    string += ":%S" if opts[:seconds]
    Time.at(ts).strftime(string)
  end

  def collection_select_with_selected(object, method, collection, value_method, text_method, current_value=nil)
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
  end

  def button_to_remote(name, options = {}, html_options = {})
    button_to_function(name, remote_function(options), html_options)
  end

  def is_adm?(user=@user)
    return false unless user.is_a? User
    user.is_adm?
  end

  def is_supermod?(user=@user)
    return false unless user.is_a? User
    user.is_supermod?
  end

  def is_file_adm?(user=@user)
    return false unless user.is_a? User
    FileController.new.send(:is_adm?, user)
  end

  def format_button(tag, image, title='')
    link_to(
      image_tag('http://www.studentibicocca.it/portale/forum/images/' + image, :border => 0),
      "javascript:bbfontstyle('[#{tag}]', '[/#{tag}]');",
      :title => title
    )
  end

  def link_legacy(params={})
    msg        = params[:caption]
    old_url    = params[:old]
    new_url    = params[:new]
    html_class = params[:class]
    if @legacy_mode == :old
      s                = link_to msg, old_url
    else
      link             = new_url
      link[:host]      = @host_forum if @host_forum
      link[:only_path] = false if @host_forum
      s                = link_to msg, link
    end
    content_tag('span', s, :class => html_class)
  end

end


class String
  def scan_words
    s = self.strip
    return [] if !s
    return [] if s == ""
    a = s.scan(/("[^"]+"|[^ ]+)/)
    a.each do |s|
      s[0].gsub!(/^"(.*)"$/, "\\1")
    end
    a.flatten!
  end
end
