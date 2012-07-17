Contribute::Application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  
  #Comments
  resources :comments do
    delete :delete, :on => :member
  end
  
  #Updates
  resources :updates, :only => [:create]
  
  #Users
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
	match 'projects/:id/activate' => 'projects#activate', :as => :activate_project
	match 'projects/:id/edit/upload' => 'projects#upload', :as => :upload_project_video
	resources :projects, :only => [:index, :new, :create, :edit, :update, :show, :destroy]
	
	#Videos
	match 'videos/:id/destroy' => 'videos#destroy', :as => :destroy_video
	
	#Groups
	match 'groups/index' => 'groups#index'
	match 'groups/:id/admin' => 'groups#admin'
	match 'groups/:id/submit' => 'groups#submit', :as => :submit_group
	match 'groups/:id/approval' => 'groups#approval'
	resources :groups
	
	root :to => 'projects#index'
	
	mount Ckeditor::Engine => "/ckeditor"

end
