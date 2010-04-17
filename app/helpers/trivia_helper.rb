module TriviaHelper

  def trivia_link_to_recent_user(user)
    s  = link_to(cleanup(user.username), user)
    s << " di #{cleanup(user.location)}" unless user.location.blank?
    s << ", da Facebook" unless user.fbid.blank?
    s
  end

end
