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
    links  = []
    # first, current and last are items and not pages if ipp is present
    # so we convert them to pages
    if (ipp)
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
    if cur
      if cur > first
        if extral.include?(:first)
          if ipp
            ctrl_opts[:start] = (first - 1) * ipp + 1
          else
            ctrl_opts[:page] = first
          end
          links << [ link_to(label[:first], ctrl_opts), :start ]
        end
        if extral.include?(:back)
          if ipp
            ctrl_opts[:start] = (cur - 2) * ipp + 1
          else
            ctrl_opts[:page] = cur - 1
          end
          links << [ link_to(label[:back], ctrl_opts), :back ]
        end
      end
    else
      if extral.include?(:first)
        if ipp
          ctrl_opts[:start] = (first - 1) * ipp + 1
        else
          ctrl_opts[:page] = first
        end
        links << [ link_to(label[:first], ctrl_opts), :start ]
      end
    end

    # numbered pages loop
    prev = first
    pages.sort.uniq.each do |p|
      if p > prev + 1
        if ipp
          ctrl_opts[:start] = ((prev + p) / 2 - 1) * ipp + 1
        else
          ctrl_opts[:page] = ((prev + p) / 2 -1 ) + 1
        end
        links << [ link_to('...', ctrl_opts), p ]
      end
      if cur
        if p == cur
          links << [ link_to(p, '#'), :current ]
        else
          if ipp
            ctrl_opts[:start] = (p - 1) * ipp + 1
          else
            ctrl_opts[:page] = p
          end
          links << [ link_to(p, ctrl_opts), p ]
        end
      else
        if ipp
          ctrl_opts[:start] = (p - 1) * ipp + 1
        else
          ctrl_opts[:page] = p
        end
        links << [ link_to(p, ctrl_opts), p ]
      end
      prev = p
    end

    # forward and last links
    if cur
      if cur < last
        if extral.include?(:forward)
          if ipp
            ctrl_opts[:start] = cur * ipp + 1
          else
            ctrl_opts[:page] = cur + 1
          end
          links << [ link_to(label[:forward], ctrl_opts), :forward ]
        end
        if extral.include?(:last)
          if (ipp)
            ctrl_opts[:start] = (last - 1) * ipp + 1
          else
            ctrl_opts[:page] = last
          end
          links << [ link_to(label[:last], ctrl_opts), :last ]
        end
      end
    else
      if extral.include?(:last)
        if ipp
          ctrl_opts[:start] = (last - 1) * ipp + 1
        else
          ctrl_opts[:page] = last
        end
        links << [ link_to(label[:last], ctrl_opts), :last ]
      end
    end

    return '' if cur && cur == first && cur == last
    content_tag('ul', :class => 'page_seq') do
      links.collect { |l| content_tag('li', l[0], :class => "page_#{l[1]}") }
    end
  end

end
