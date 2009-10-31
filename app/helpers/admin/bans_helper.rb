module Admin::BansHelper

  def page_trail_admin_bans(obj, opts={})
    [ [ "Amministrazione", admin_path ], [ "Espulsioni in corso", nil ] ]
  end

  def page_trail_admin_ban(obj, opts={})
    if obj.new_record?
      current = [ "Nuova espulsione", nil ]
    else
      current = [ "Espulsione di #{cleanup(obj.user.username)} da #{cleanup(obj.forum.name)}", nil ]
    end
    [ [ "Amministrazione", admin_path ], [ "Espulsioni", admin_bans_path ], current ]
  end

end
