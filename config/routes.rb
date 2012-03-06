Contribute::Application.routes.draw do
  get "payments/new"

  devise_for :users, :controllers => { :registrations => :registrations, :confirmations => :confirmations }

	devise_scope :user do
		get 'users/show/:id', :to => 'registrations#show', :as => :user
	end

	#Contribution resource routes  
	match 'contribution/:project' => 'contributions#new', :as => :new_contribution
	match 'contribution/save' => 'contributions#save', :as => :save_contribution
	match 'contribution/cancel' => 'contributions#cancel', :as => :cancel_contribution
	resources :contributions, :only => :create

	#The :id being passed through the routes is really the name of the project
  resources :projects

  root :to => 'projects#index'
end
