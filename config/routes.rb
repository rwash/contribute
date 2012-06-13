Contribute::Application.routes.draw do

	resources :videos do    
    new do
       post :upload
       get  :save_video
     end
  end
  
  resources :comments do
    delete :delete, :on => :member
  end
  
  resources :updates, :only => [:create]

  devise_for :users, :controllers => { :registrations => :registrations, :confirmations => :confirmations }

	devise_scope :user do
		get 'users/show/:id', :to => 'registrations#show', :as => :user
	end

	#Contribution resource routes  
	match 'contributions/new/:project' => 'contributions#new', :as => :new_contribution
	match 'contributions/save' => 'contributions#save', :as => :save_contribution
	match 'contributions/update_save' => 'contributions#update_save', :as => :update_save_contribution
	match 'contributions/execute/:id' => 'contributions#executePayment', :as => :execute_contribution
	match "more" => "registrations#more", :as => "more"
	resources :contributions, :only => [:create, :edit, :show, :update]

	#The :id being passed through the routes is really the name of the project
	match 'projects/save' => 'projects#save', :as => :save_project
	match 'projects/:id/edit/upload' => 'projects#upload', :as => :upload_project_video
	resources :projects, :only => [:index, :new, :create, :edit, :update, :show, :destroy]

	root :to => 'projects#index'

end
