ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.resources :users, :collection => { :login => :get, :fbconnect => :get, :logout => :get, :authenticate => :post, :fblink => :post, :recover_password => :get, :send_password => :post }, :has_many => :smileys
  map.resources :pms, :member => { :reply => :get, :post_reply => :get }, :new => { :save_draft => :post, :draft => :get }, :collection => { :backup => :get }
  map.resources :drafts, :path_prefix => 'forum', :has_one => [ :post, :pm, :topic ]
  map.resources :posts, :path_prefix => 'forum', :member => { :reply => :get, :report => :get, :send_report => :post }, :new => { :save_draft => :post, :draft => :get }, :collection => { :backup => :get }
  map.resources :topics, :path_prefix => 'forum', :has_many => :posts, :new => { :save_draft => :post, :draft => :get }
  map.resources :forums, :path_prefix => 'forum', :has_many => [ :topics, :posts ]
  map.resources :blogs, :path_prefix => 'blog', :has_many => :blog_posts
  map.resources :blog_posts, :path_prefix => 'blog', :has_many => :comments
  map.resources :comments
  map.resources :smileys
  map.resources :announcements
  map.namespace(:admin) do |admin|
    admin.resources :cms_pages 
    admin.resources :announcements
    admin.resources :forums
    admin.resources :banners
    admin.resources :bans
    admin.resources :custom_stylesheets
    admin.resource  :staff, :controller => 'staff'
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => 'cms_pages', :action => 'show', :slug => 'welcome'

  map.admin           '/admin', :controller => 'admin', :action => 'index'
  map.forum_root      '/forum', :controller => 'forums', :action => 'index'
  map.full_topic      '/forum/topics/full/:id.:format', :controller => 'topics', :action => 'full'
  map.custom_css      '/custom_css/:obj_class/:obj_id.css', :controller => 'custom_stylesheets', :action => 'show'
  map.css             '/css/:name.:format', :controller => 'css', :action => 'view'
  map.object_vote     '/vote/:type/:id/:points', :controller => 'votes', :action => 'vote'
  map.object_tag_set  '/tag/set/:type/:id', :controller => 'tags', :action => 'set'
  map.object_tag_edit '/tag/edit/:type/:id', :controller => 'tags', :action => 'edit'
  map.search_tags     '/search/tags/:tags', :controller => 'search', :action => 'search', :requirements => { :tags => /.*/ }
  map.search          '/search', :controller => 'search', :action => 'search'
  map.banners         '/banners/show', :controller => 'banners', :action => 'show'
  map.notifications   '/notifications', :controller => 'notifications', :action => 'index'
  map.trivia          '/trivia', :controller => 'trivia', :action => 'index'

  # SEO routes
  map.tag_index     'tags', :controller => 'tags', :action => 'index'
  map.blog_backup   'blogs/:username/backup.:format', :controller => 'blogs', :action => 'backup', :requirements => { :username => /[^0-9\/][^\/]+/ }
  map.blog_index    '/blogs', :controller => 'blogs', :action => 'index'
  map.cms_page      '/cms/:slug', :controller => 'cms_pages', :action => 'show'
  map.seo_blog_post 'blogs/:username/:id/:slug', :controller => 'blog_posts', :action => 'show', :requirements => { :username => /[^0-9\/][^\/]+/, :id => /[0-9]+/ }
  map.blog_view     'blogs/:username/:slug', :controller => 'blogs', :action => 'show', :requirements => { :username => /[^0-9\/][^\/]+/ }
  map.blog_list     'blogs/:username', :controller => 'blogs', :action => 'index', :requirements => { :username => /.*/ }

  # legacy routes - these have to go sooner or later
  map.connect 'blog_posts/:action/:id', :controller => 'blog_posts'
  map.connect 'blog_posts/:action/:id.:format', :controller => 'blog_posts'
  map.connect 'drafts/:action/:id', :controller => 'drafts'
  map.connect 'drafts/:action/:id.:format', :controller => 'drafts'
  map.connect 'pms/:action/:id', :controller => 'pms'
  map.connect 'pms/:action/:id.:format', :controller => 'pms'
  map.connect 'text_preview/:action/:id', :controller => 'text_preview'
  map.connect 'text_preview/:action/:id.:format', :controller => 'text_preview'
  map.connect 'static_content/:action/:id', :controller => 'static_content'
  map.connect 'static_content/:action/:id.:format', :controller => 'static_content'
  map.connect 'group/:action/:id', :controller => 'group'
  map.connect 'file/:action/:id', :controller => 'file'
  map.connect 'file/:action/:id.:format', :controller => 'file'

  # See how all your routes lay out with "rake routes"
  # Install the default routes as the lowest priority.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
