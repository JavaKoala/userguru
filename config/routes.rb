Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :issues, only: [:index, :show, :create, :update]
      resources :comments, only: [:create, :update]
      resources :sessions, only: :index
    end
  end

  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  root 'static_pages#home'
  get    'help'   => 'static_pages#help'
  get    'about'  => 'static_pages#about'
  get    'signup' => 'users#new'
  get    'login'  => 'sessions#new'
  post   'login'  => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  resources :users
  resources :issues
  resources :comments,            only: [:create, :update, :destroy]
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :settings,            only: [:index, :update]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
