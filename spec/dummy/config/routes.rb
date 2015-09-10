Rails.application.routes.draw do
  mount Maia::Engine => "/maia"
  resources :devices
end
