Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"

      # User profile
      get "users/me", to: "users#me"

      # Books
      resources :books
    end
  end

  # Authentication routes (outside namespace for Devise compatibility)
  devise_for :users, path: "api/v1/auth", path_names: {
    sign_in: "sign_in",
    sign_out: "sign_out",
    registration: "sign_up"
  }, controllers: {
    sessions: "api/v1/auth/sessions",
    registrations: "api/v1/auth/registrations"
  }

  # Defines the root path route ("/")
  # root "posts#index"
end
