Rails.application.routes.draw do
  root to: "home#show"

  resources :sessions, only: %i[ index new create show destroy ]

  resources :events do
    member do
      post :finalize
      post :ready
      post :audit
      post :redraw
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

  resources :consumables do
    resources :notes, only: %i[ create ], controller: "consumables/notes"
    resources :transactions, only: %i[ create destroy ], controller: "consumable_transactions"

    resources :images, only: %i[ update destroy ], controller: "entities/images" do
      member do
        patch :left
        patch :right
      end
    end
  end

  resources :products do
    resources :notes, only: %i[ create ], controller: "products/notes"
    resources :instances, only: %[destroy], controller: "products/instances" do
      member do
        patch :hold
        patch :send_for_repairs
        patch :repair
      end
    end

    resources :images, only: %i[ update destroy ], controller: "entities/images" do
      member do
        patch :left
        patch :right
      end
    end
  end

  resources :notes

  get "/apple-touch-icon/:size.:format", to: "home#apple_touch_icon"
  get "/favicon/:size.:format", to: "home#apple_touch_icon"
end
