Contribute::Application.routes.draw do
 	#explicitly use our subclass controller
  devise_for :users, :controllers => { :registrations => :registrations, :confirmations => :confirmations, :omniauth_callbacks => :omniauth_callbacks } do		
		get 'users/show/:id', :to => 'registrations#show', :as => :user
	end

	#The :id being passed through the routes is really the name of the project
  resources :projects

  root :to => 'projects#index'
end
