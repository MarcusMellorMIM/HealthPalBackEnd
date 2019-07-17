Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [ :show, :create, :update]
  resources :weights, only: [ :show, :create, :destroy, :update]
  resources :meals, only: [ :show, :create, :destroy, :update]
  resources :exercises, only: [ :show, :create, :destroy, :update]

  post "/auth/create", to: "auth#create"
  get "/auth/show", to: "auth#show"

  get "/weights/user/:id", to: "weights#index", as: "weightindex"
  get "/meals/user/:id", to: "meals#index", as: "mealindex"
  get "/exercises/user/:id", to: "exercises#index", as: "exerciseindex"

  post "/api/food", to: "api#food", as: "apifood"
  post "/api/exercise", to: "api#exercise", as: "apiexercise"
end
