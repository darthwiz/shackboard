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

  map.resources :users, :collection => { :login => :get, :logout => :get, :authenticate => :post, :recover_password => :get, :send_password => :post }, :has_many => :smileys
  map.resources :pms, :member => { :reply => :get, :post_reply => :get }, :new => { :save_draft => :post, :draft => :get }
  map.resources :drafts, :path_prefix => 'forum', :has_one => [ :post, :pm, :topic ]
  map.resources :posts, :path_prefix => 'forum', :member => { :reply => :get }, :new => { :save_draft => :post, :draft => :get }
  map.resources :topics, :path_prefix => 'forum', :has_many => :posts
  map.resources :forums, :path_prefix => 'forum', :has_many => [ :topics, :posts ]
  map.resources :blogs, :path_prefix => 'blog', :has_many => :blog_posts
  map.resources :blog_posts, :path_prefix => 'blog', :has_many => :blog_comments
  map.resources :blog_comments, :path_prefix => 'blog'
  map.resources :smileys
  map.namespace(:admin) do |admin|
    admin.resources :cms_pages 
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => 'welcome'

  map.full_topic '/forum/topics/full/:id.:format', :controller => 'topics', :action => 'full'
  map.css        '/css/:name.:format', :controller => 'css', :action => 'view'

  # SEO routes
  map.blog_index    '/blogs', :controller => 'blogs', :action => 'index'
  map.cms_page      '/cms/:slug', :controller => 'cms_pages', :action => 'show'
  map.seo_blog_post 'blogs/:username/:id/:slug', :controller => 'blog_posts', :action => 'show', :requirements => { :id => /[0-9]+/ }
  map.blog_view     'blogs/:username/:blog_label', :controller => 'blogs', :action => 'show', :requirements => { :username => /[^0-9]+/, :blog_label => /.*/ }
  map.blog_list     'blogs/:username', :controller => 'blogs', :action => 'index', :requirements => { :username => /.*/ }


  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
