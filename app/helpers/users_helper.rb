module UsersHelper

  def status_list(user=@user)
    statuses   = []
    mod_forums = user.moderates
    statuses << t(sexified(:Administrator, user.sex)) if user.is_adm?
    statuses << t(sexified(:SuperModerator, user.sex)) if (user.is_supermod? && !user.is_adm?)
    statuses << t(sexified(:Moderator, user.sex)) + ' di ' + mod_forums.collect { |i| link_to(cleanup(i.name), i) }.join(', ') unless mod_forums.empty?
    statuses << user.rank.title
    statuses.join(', ')
  end

  def page_trail_user(obj, opts={})
    trail  = []
    trail << [ "Profilo di #{cleanup(obj.username)}", {} ]
  end

end
