Rails.application.routes.draw do
  resources :events do
    member do
      resources :reservations, only: %i[ index create destroy ], controller: "events/reservations"
    end
  end

  resources :products
  resources :users
  resources :groups
end
