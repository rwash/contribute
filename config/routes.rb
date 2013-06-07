Contribute::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  #Comments
  resources :comments

  #Updates
  resources :updates, :only => [:create]

  #Users
  devise_for :users, :controllers => { :registrations => :registrations, :confirmations => :confirmations }
  # TODO take these out of devise, and move them to the users resource
  devise_scope :user do
    get 'users/show/:id', :to => 'registrations#show', :as => :user
  end
  resources :users do
    post 'block', on: :member
    post 'toggle_admin', on: :member
  end

  #Contribution resource routes
  match 'contributions/new/:project' => 'contributions#new', :as => :new_contribution
  match 'contributions/save' => 'contributions#save', :as => :save_contribution
  match 'contributions/update_save' => 'contributions#update_save', :as => :update_save_contribution
  match 'contributions/execute/:id' => 'contributions#executePayment', :as => :execute_contribution
  match "more" => "registrations#more", :as => "more"
  resources :contributions, :only => [:create, :edit, :update]

  #The :id being passed through the routes is really the name of the project
  match 'projects/save' => 'projects#save', :as => :save_project
  match 'projects/:id/edit/upload' => 'projects#upload', :as => :upload_project_video
  resources :projects, :only => [:index, :new, :create, :edit, :update, :show, :destroy] do
    put 'activate', on: :member
    put 'block', on: :member
    put 'unblock', on: :member
  end

  #Videos
  match 'videos/:id/destroy' => 'videos#destroy', :as => :destroy_video

  #Groups
  match 'groups/index' => 'groups#index'
  match 'groups/:id/admin' => 'groups#admin', :as => :group_admin
  match 'groups/:id/destroy' => 'groups#destroy', :as => :destroy_group
  match 'groups/:id/approvals/:approval_id/reject-form' => 'groups#admin', :as => :reject_approval_form

  match 'groups/:id/new-add' => 'groups#new_add', :as => :new_add
  match 'groups/:id/submit-add' => 'groups#submit_add', :as => :submit_add
  match 'groups/:id/projects/:project_id/remove' => 'groups#remove_project', :as => :remove_project_from_group
  match 'groups/:group_id/approvals/:id/approve' => 'approvals#approve', :as => :approve_approval
  match 'groups/:group_id/approvals/:id/reject' => 'approvals#reject', :as => :reject_approval

  resources :groups

  # Static pages, through HighVoltage
  match '/pages/*id' => 'pages#show', as: :page, format: false

  root :to => 'projects#index'

  mount Ckeditor::Engine => "/ckeditor"

end
