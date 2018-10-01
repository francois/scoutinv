Rails.application.routes.draw do
  root to: "home#show"

  resources :sessions, only: %i[ index new create show destroy ]

  resources :events do
    member do
      post :notify
    end
    resources :notes, only: %i[ create ], controller: "events/notes"
    resources :products, only: %i[ show ], controller: "events/products"
    resources :reservations, only: %i[ index create destroy ], controller: "events/reservations"
  end

  resources :reservations, only: %i[ update ]

  resources :groups do
    resources :members, only: %i[ create ]
    resources :troops,  only: %i[ create ]
  end

  resources :members, only: %i[ edit update destroy ]

  resources :troops, only: %i[ edit update destroy ]

  resources :reports, only: %i[ index show ]

  resources :products do
    resources :instances, only: %[destroy], controller: "products/instances" do
      member do
        patch :hold
        patch :send_for_repairs
        patch :repair
      end
    end

    resources :images, only: %i[ update destroy ], controller: "products/images" do
      member do
        patch :left
        patch :right
      end
    end
    resources :notes, only: %i[ create ], controller: "products/notes"
  end

  resources :notes

  get "/apple-touch-icon/:size.:format", to: "home#apple_touch_icon"
  get "/favicon/:size.:format", to: "home#apple_touch_icon"
end
