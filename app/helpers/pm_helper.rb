module PmHelper
  def page_trail_Pm(loc) # {{{
    trail = []
    case loc[1]
    when 'inbox'
      trail << [ 'Messaggi privati', {} ]
    when 'trash'
      trail << [ 'Messaggi privati', {:controller => 'pm', :action => 'list'} ]
      trail << [ 'Cestino', {} ]
    when :new
      trail << [ 'Messaggi privati', {:controller => 'pm', :action => 'list'} ]
      trail << [ 'Nuovo', {} ]
    end
    trail
  end # }}}
end
