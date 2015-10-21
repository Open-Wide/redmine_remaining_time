# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  match 'load_following', :controller => :load_following, :action => :index, :via => :get, :as => "load_following"
end