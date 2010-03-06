module VotesHelper

  def button_for_voting(obj)
    return unless @user
    like_url_opts        = { :controller => :votes, :action => :vote, :type => obj.class.to_s, :id => obj.id, :points => 1 }
    indifferent_url_opts = { :controller => :votes, :action => :vote, :type => obj.class.to_s, :id => obj.id, :points => 0 }
    dislike_url_opts     = { :controller => :votes, :action => :vote, :type => obj.class.to_s, :id => obj.id, :points => -1 }
    span_id              = 'vote_' + domid(obj)
    votes                = obj.votes
    user_voted_for       = votes.select { |v| v.points > 0 }.collect(&:user_id).include?(@user.id)
    user_voted_against   = votes.select { |v| v.points < 0 }.collect(&:user_id).include?(@user.id)
    link_for             = link_to_remote('mi piace',     :url => like_url_opts,        :html => { :class => 'active' }) 
    link_against         = link_to_remote('non mi piace', :url => dislike_url_opts,     :html => { :class => 'active' })
    link_indifferent     = link_to_remote('?',            :url => indifferent_url_opts, :html => { :class => 'active' })
    inactive_for         = content_tag(:span, 'mi piace',     :class => 'inactive', :title => 'non mi piace')
    inactive_against     = content_tag(:span, 'non mi piace', :class => 'inactive', :title => 'non mi interessa')
    inactive_indifferent = content_tag(:span, '?',            :class => 'inactive', :title => 'mi piace')
    if user_voted_for
      html = vote_3_links(link_against, link_indifferent, inactive_for)
    elsif user_voted_against
      html = vote_3_links(inactive_against, link_indifferent, link_for)
    else
      html = vote_3_links(link_against, inactive_indifferent, link_for)
    end
    content_tag(:span, html, :class => 'voting_links', :id => span_id)
  end

  private

  def vote_3_links(link_against, link_indifferent, link_for)
    [
      content_tag(:span, link_against,     :class => 'dislike',     :title => 'non mi piace'),
      content_tag(:span, link_indifferent, :class => 'indifferent', :title => 'non mi interessa'),
      content_tag(:span, link_for,         :class => 'like',        :title => 'mi piace'),
    ].join(' ')
  end

end
