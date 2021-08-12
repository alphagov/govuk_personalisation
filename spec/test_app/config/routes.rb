Rails.application.routes.draw do
  get "/show", to: "sessions#show", as: :show_session
  get "/callback", to: "sessions#callback", as: :callback_session
  get "/update", to: "sessions#update", as: :update_session
  get "/delete", to: "sessions#delete", as: :delete_session
end
