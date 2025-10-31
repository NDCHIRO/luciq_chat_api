Rails.application.routes.draw do
  get "home/index"
  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :applications, param: :token, only: [:create, :show, :update] do
    get :message_count, on: :member
    resources :chats, param: :chat_number, only: [:index, :create, :show] do
      resources :messages, param: :message_number, only: [:index, :create, :show] do
        get :search, on: :collection
      end
    end
  end
end
