Rails.application.routes.draw do
  resources :sessions
  resources :thefts
  resources :stations
  resources :streams
  resources :lands
  resources :countries
  resources :districts
  resources :cities
  get 'static_pages/help'

  get 'static_pages/home'

  get    '/home',    to: 'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  post   'thefts/run/:id' => 'thefts#run', :as => :run
  root   'static_pages#home'
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
