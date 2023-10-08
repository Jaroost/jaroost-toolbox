Rails.application.routes.draw do

  get "keycloak/reset_configuration"
  get "keycloak/impersonate"
  get "keycloak/impersonate_logout"
  get "keycloak/:keycloak_user_id/impersonate" => "keycloak#impersonate_user", as: :impersonate_user
  get "keycloak/change_locale"

  devise_scope :user do
    get '/after_logout' => "users/omniauth_callbacks#logout", as: :post_logout
    get '/after_register' => "users/omniauth_callbacks#after_register"
  end


  devise_for :users, controllers: {
    # registrations: 'users/registrations',
    # sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resources :clients
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#welcome"
  get 'home/signed_welcome'
  match 'home/test', via: [:get, :post], as: :test_page
  #get 'home/after_login'

  match 'models/grid_search' => 'entities#grid_search', via: [:get, :post], as: 'models_grid_search'
  post 'vue_grids/save_preferences' => 'entities#save_preferences'

end
