Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # ActionCable endpoint (Turbo Streams)
  mount ActionCable.server => "/cable"

  # WhatsApp Web-style UI
  root "conversations#index"
  resources :conversations, only: [ :index, :show ] do
    resource  :read,     only: :create, controller: "conversation_reads"
    resources :messages, only: :create
  end
  resources :contacts, only: [ :show, :update ]

  # WhatsApp webhooks — Meta sends both GET (verification handshake)
  # and POST (events) to the same callback URL.
  namespace :webhooks do
    get  "whatsapp", to: "whatsapp#verify"
    post "whatsapp", to: "whatsapp#receive"
  end
end
