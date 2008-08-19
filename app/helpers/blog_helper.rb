module BlogHelper
  def page_trail_Blog(loc) 
    trail  = []
    loc    = loc[1]
    if loc.is_a? User
      trail << [ 'Blog', { :controller => :blog, :action => :index } ]
      trail << [ loc.username, {} ]
    elsif loc.is_a? Blog
      trail << [ 'Blog', { :controller => :blog, :action => :index } ]
      trail << [ loc.user.username, { :controller => :blog, :action => :list, :username => loc.user.username } ]
      trail << [ loc.name, {} ]
    end
    trail
  end 

end
