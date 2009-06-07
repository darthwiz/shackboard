module UsersHelper

  def status_list(user=@user)
    statuses   = []
    mod_forums = user.moderates
    statuses << 'Amministratore' if user.is_adm?
    statuses << 'Super moderatore' if (user.is_supermod? && !user.is_adm?)
    statuses << 'Moderatore di ' + mod_forums.collect { |i| link_to(cleanup(i.name), i) }.join(', ') unless mod_forums.empty?
    statuses << user.rank.title
    statuses.join(', ')
  end

  def page_trail_user(obj, opts={})
    trail  = []
    trail << [ "Profilo di #{cleanup(obj.username)}", {} ]
  end

end
