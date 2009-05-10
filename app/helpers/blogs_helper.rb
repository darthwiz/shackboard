module BlogsHelper
  def page_trail_Blog(loc) 
    trail  = []
    loc    = loc[1]
    if loc.is_a? User
      trail << [ 'Blog', { :controller => :blogs, :action => :index } ]
      trail << [ loc.username, {} ]
    elsif loc.is_a? Blog
      trail << [ 'Blog', { :controller => :blogs, :action => :index } ]
      trail << [ loc.user.username, { :controller => :blogs, :action => :index, :username => loc.user.username } ]
      trail << [ loc.name, {} ]
    end
    trail
  end 

end
