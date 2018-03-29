Rails.application.routes.draw do
  root to: "home#show"

  resources :groups
  resources :sessions, only: %i[ index new create show destroy ]
  resources :users

  resources :events do
    resources :reservations, only: %i[ index create destroy ], controller: "events/reservations"
    resources :notes, only: %i[ create ], controller: "events/notes"
  end

  resources :products do
    resources :notes, only: %i[ create ], controller: "products/notes"
  end
end
