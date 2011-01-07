ActionController::Routing::Routes.draw do |map|

  map.connect "/sitemap.:type", :controller => "sitemap", :action => "index"
  map.connect "/sitemap_news.:type", :controller => "sitemap", :action => "index", :news => true

  map.connect "/posts/:filter", :controller => "posts", :action => "index", :requirements => { :filter => /favorited|featured|viewed/  }
  map.resources :posts, :member => { :publish => :put, :unpublish => :put, :favorite => :get, :featured => :get, :tweet => :get, :facebook => :get, :set_as_home_page => :get } do |post|
    post.resources :comments, :except => [:index, :show]
  end

  map.connect "/pages/:filter", :controller => "pages", :action => "index", :requirements => { :filter => /favorited|featured|viewed/  }
  map.resources :pages, :member => { :publish => :put, :unpublish => :put, :favorite => :get, :featured => :get, :set_as_home_page => :get } do |page|
    page.resources :comments, :except => [:index, :show]
  end

  map.resources :comments, :member => { :report_as_spam => :put, :report_as_ham => :put }, :collection => { :ham => :get, :spam => :get, :delete_spam => :get }

  map.connect "/category/:seo_name/:tab", :controller => "categories", :action => "show_category", :tab => nil
  map.resources :categories
  
  map.connect "/tags/suggest", :controller => "tags", :action => "suggest"
  map.resources :tags do |tag|
    tag.connect ":tab", :controller => "tags", :action => "show", :requirements => { :tab => /posts|pages/  }
  end

  map.resources :profiles, :member => { :favorite => :get, :featured => :get } do |profile|
    profile.connect ":tab", :controller => "profiles", :action => "show", :requirements => { :tab => /posts|comments/  }
  end

  map.namespace :account do |account|
    account.resource :twitter_account, :member => { :callback => :any }
    account.resource :facebook_account, :member => { :callback => :any, :connect => :any }
    account.resources :settings, :member => { :update => :any }
    account.resource :notification_setting, :member => { :update => :any }
  end
  
  map.connect "/login", :controller => "profiles", :action => "login"
  map.connect "/forgot_your_password", :controller => "profiles", :action => "recover"
  map.connect "/reset_password/:temp", :controller => "profiles", :action => "reset_password", :temp => nil
  map.connect "/logout", :controller => "profiles", :action => "logout"
  map.connect "/connect", :controller => "profiles", :action => "connect"

  map.search '/search', :controller => 'search', :action => "index"
  map.connect "/search/:search_term/:tab", :controller=>"search", :action => "index", :tab=>nil 

  map.connect "/rss", :controller => "posts", :action => "index", :format=>"rss"

  map.namespace :admin do |admin|
    admin.resource :incoming, :only => [:create]
    admin.resource :sites
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.connect "/:filter", :controller => "posts", :action => "index", :requirements => { :filter => /favorited|featured|viewed/  }
  map.root :controller => "homes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end