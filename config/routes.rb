Maia::Engine.routes.draw do
  post 'messages/push', to: 'messages#push', as: :push
  root to: 'messages#new'
end
