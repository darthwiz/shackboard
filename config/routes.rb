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

  map.resources :users

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
  map.blog_list 'blogs/:username', :controller => 'blog', :action => 'list', :requirements => blog_reqs
  map.blog_view 'blogs/:username/:blog_label', :controller => 'blog', :action => 'view', :requirements => blog_reqs
  map.blog_view 'blogs/:username/:blog_label/:category_label', :controller => 'blog', :action => 'view', :requirements => blog_reqs

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
