Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"

    resources :products
    resources :microposts, only: [:index]

    get "static_pages/home"
    get "static_pages/help"
    get "static_pages/contact"
    
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    resources :users
    resources :account_activations, only: [:edit]
    resources :password_resets, only: %i(new create edit update)
  end
end
