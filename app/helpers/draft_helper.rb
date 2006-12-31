module DraftHelper
  def page_trail_Draft(loc) # {{{
    trail = []
    case loc
    when :list
      trail << [ 'Bozze', {} ]
    end
    trail
  end # }}}
end
