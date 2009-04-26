module PmsHelper
  def page_trail_Pm(loc) # {{{
    trail = []
    case loc[1]
    when 'inbox'
      trail << [ 'Messaggi privati', {} ]
    when 'trash'
      trail << [ 'Messaggi privati', pms_path ]
      trail << [ 'Cestino', {} ]
    when :new
      trail << [ 'Messaggi privati', pms_path ]
      trail << [ 'Nuovo', {} ]
    end
    trail
  end # }}}
end
