Contribute::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => :registrations, :confirmations => :confirmations }

	devise_scope :user do
		get 'users/show/:id', :to => 'registrations#show', :as => :user
	end

	#Contribution resource routes  
	match 'contributions/new/:project' => 'contributions#new', :as => :new_contribution
	match 'contributions/save' => 'contributions#save', :as => :save_contribution
	match 'contributions/execute/:id' => 'contributions#executePayment', :as => :execute_contribution
	resources :contributions, :only => :create

	#The :id being passed through the routes is really the name of the project
	match 'projects/save' => 'projects#save', :as => :save_project
  resources :projects

  resources :payments, :only => :new
	match "/payments/multi_token_return" => "payments#multi_token_return", :via => :get
	match "/payments/recipient_return" => "payments#recipient_return", :via => :get

  root :to => 'projects#index'
end
