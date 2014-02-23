Contribute::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  #Comments
  resources :comments

  #Users
  devise_for :users, :controllers => { :registrations => :registrations, :confirmations => :confirmations }
  resources :users do
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
  match 'projects/:id/edit/upload' => 'projects#upload', :as => :upload_project_video
  resources :projects, :only => [:index, :new, :create, :edit, :update, :show, :destroy] do
    resources :updates, only: [:new, :create]
    resources :amazon_payment_accounts, only: [:new, :create, :destroy]
    put 'activate', on: :member
  end
  get 'projects/:project_id/amazon_payment_accounts' => 'amazon_payment_accounts#create'

  #Videos
  match 'videos/:id/destroy' => 'videos#destroy', :as => :destroy_video

  #Groups
  match 'groups/index' => 'groups#index'
  match 'groups/:id/destroy' => 'groups#destroy', :as => :destroy_group
  match 'groups/:id/approvals/:approval_id/reject-form' => 'groups#admin', :as => :reject_approval_form

  match 'groups/:id/projects/:project_id/remove' => 'groups#remove_project', :as => :remove_project_from_group

  resources :groups do
    resources :approvals, only: [:index, :new, :create] do
      put :approve, on: :member
      put :reject, on: :member
    end
  end

  # Static pages, through HighVoltage
  match '/pages/*id' => 'pages#show', as: :page, format: false

  root :to => 'projects#index'

  mount Ckeditor::Engine => "/ckeditor"

end
