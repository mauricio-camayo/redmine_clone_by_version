#get 'clone', :to => 'clone#index'
#post 'clone/doclone', :to => 'clone#doclone'


resources :clone_queries


get '/projects/:project_id/clone/', :to => "clone#index"
post '/projects/:project_id/clone/doclone', :to => 'clone#doclone'