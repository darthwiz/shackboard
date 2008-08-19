module BlogPostHelper
  def page_trail_Blog(loc) 
    trail  = []
    loc    = loc[1]
    if loc.is_a? User
      trail << [ 'Blog', { :controller => :blog_post, :action => :index } ]
      trail << [ loc.username, {} ]
    end
    trail
  end 

end
