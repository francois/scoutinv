Rails.application.routes.draw do
  resources :events do
    member do
      resources :reservations, only: %i[ index create destroy ], controller: "events/reservations"
    end
  end

  resources :groups
  resources :products
  resources :sessions, only: %i[ index new create show destroy ]
  resources :users
end
