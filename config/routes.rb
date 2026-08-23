Rails.application.routes.draw do
  resources :events, only: [ :index, :show ] do
    resources :votes, only: [ :create ]
  end

  root "events#index"
  delete "sign_out" => "sessions#destroy", as: :sign_out
end
