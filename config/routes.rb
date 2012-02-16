Contribute::Application.routes.draw do
 	#explicitly use our subclass controller
  devise_for :users, :controllers => { :registrations => :registrations } do		
		get 'users/show/:id', :to => 'registrations#show', :as => :user
	end

	#The :id being passed through the routes is really the name of the project
  resources :projects

  root :to => 'projects#index'
end
