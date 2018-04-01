Rails.application.routes.draw do
  root to: "home#show"

  resources :sessions, only: %i[ index new create show destroy ]

  resources :events do
    member do
      get :print
    end

    resources :reservations, only: %i[ index create destroy ], controller: "events/reservations"
    resources :notes, only: %i[ create ], controller: "events/notes"
  end

  resources :groups do
    resource :users, only: %i[ create ]
  end

  resources :users, only: %i[ edit update destroy ]

  resources :products do
    resources :notes, only: %i[ create ], controller: "products/notes"
  end
end
