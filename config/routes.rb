MysteryWorks::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  
  devise_scope :user do
    get 'sign_in', :to => 'application#new', :as => :new_user_session
    get 'sign_out', :to => 'application#destroy', :as => :destroy_user_session
  end
  
  get '/user', to: 'users#user'
  
  resources :channels, :only => [:show] do
    member do
      post 'set_inactive'
      post 'open_betting'
      post 'close_betting'
      post 'complete_betting'
    end
  end
  
  resources :channel_accounts, :only => [:show] do
    member do
      post 'rest'
      post 'donate_blood'
      post 'bet'
    end
  end
end
