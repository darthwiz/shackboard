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
  map.resources :blog_posts, :path_prefix => 'blog', :has_many => :blog_comments
  map.resources :blog_comments, :path_prefix => 'blog'
  map.resources :smileys

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  blog_reqs = { :username => /.*/, :blog_label => /.*/ }
  map.root :controller => "welcome"
  #map.connect 'community', :controller => 'welcome', :action => 'community'
  #map.connect 'servizi', :controller => 'welcome', :action => 'services'
  #map.connect 'in-bicocca', :controller => 'welcome', :action => 'in_bicocca'
  #map.connect 'studiare-a-milano', :controller => 'welcome', :action => 'in_milano'
  #map.connect 'chi-siamo', :controller => 'welcome', :action => 'about_us'
  #map.connect 'mappa-del-sito', :controller => 'welcome', :action => 'sitemap'
  #map.connect 'area-personale', :controller => 'welcome', :action => 'personal'
  map.blog_view 'blogs/:username/:blog_label/:category_label', :controller => 'blog', :action => 'view', :requirements => blog_reqs
  map.blog_view 'blogs/:username/:blog_label', :controller => 'blog', :action => 'view', :requirements => blog_reqs
  map.blog_list 'blogs/:username', :controller => 'blog', :action => 'list', :requirements => blog_reqs

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
