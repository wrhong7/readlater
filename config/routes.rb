Rails.application.routes.draw do

  devise_for :users
  resources :links
  delete '/links/:id', to: 'links#destroy'
  get '/link/view', to: 'links#view', as: 'links_view'
  get '/link/share', to: 'links#share', as: 'links_share'
  get '/link/suggestion', to: 'links#suggestion', as: 'links_suggestion'
  root 'links#home'
  
end
