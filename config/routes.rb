MysteryWorks::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  
  devise_scope :user do
    get 'sign_in', :to => 'application#new', :as => :new_user_session
    get 'sign_out', :to => 'application#destroy', :as => :destroy_user_session
  end
  
  get '/user', to: 'users#user'
  get '/channel/:name', to: 'channel#show'
end
