Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [ :show, :create, :update]
  get "/usersummary", to: "users#summary", as: "usersummary"
  resources :weights, only: [ :index, :show, :create, :destroy, :update]
  resources :inputs, only: [ :index, :show, :create, :destroy, :update]
  resources :activities, only: [ :index, :show, :create, :destroy, :update]


  # resources :exercises, only: [ :show, :create, :destroy, :update]

  post "/auth/create", to: "auth#create"
  get "/auth/show", to: "auth#show"

  post "/api/input", to: "api#input", as: "apiinput"
  post "/api/activity", to: "api#activity", as: "apiactivity"
end
