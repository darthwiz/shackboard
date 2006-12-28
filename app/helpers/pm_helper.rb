module PmHelper
  def page_trail_Pm(loc) # {{{
    trail = []
    case loc
    when 'inbox'
      trail << [ 'Messaggi privati', {} ]
    when 'trash'
      trail << [ 'Messaggi privati', {:controller => 'pm', :action => 'list'} ]
      trail << [ 'Cestino', {} ]
    end
    trail
  end # }}}
end
