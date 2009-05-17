module PmsHelper

  def page_trail_pm(loc, opts={})
    trail = []
    if loc.new_record?
      trail << [ 'Messaggi privati', pms_path ]
      trail << [ 'Nuovo', {} ]
    end
    trail
  end

  def page_trail_pms(loc, opts={})
    trail = []
    case loc.first.folder
    when 'inbox'
      trail << [ 'Messaggi privati', {} ]
    when 'trash'
      trail << [ 'Messaggi privati', pms_path ]
      trail << [ 'Cestino', {} ]
    end
    trail
  end

end
