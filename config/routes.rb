Contribute::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => :registrations, :confirmations => :confirmations }

	devise_scope :user do
		get 'users/show/:id', :to => 'registrations#show', :as => :user
	end

	#The :id being passed through the routes is really the name of the project
  resources :projects

	match 'pay' => 'payments#create_pay', :as => :pay
	
  root :to => 'projects#index'
end
