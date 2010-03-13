module BlogsHelper

  def page_trail_blog(loc, opts={}) 
    trail  = []
    trail << [ 'Blog', blog_index_path ]
    trail << [ cleanup(loc.name), {} ]
    trail
  end 

  def page_trail_blog_post(loc, opts={}) 
    trail  = []
    trail << [ 'Blog', blog_index_path ]
    trail << [ cleanup(loc.blog.name), blog_view_path(loc.blog.user.username, loc.blog.slug) ]
    trail << [ loc.title, {} ] unless loc.title.blank?
    trail
  end 

  def page_trail_blogs(loc, opts={}) 
    trail  = []
    trail << [ 'Blog', {} ]
    trail
  end 

end
