module PagerHelper

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

end
