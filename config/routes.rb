MysteryWorks::Application.routes.draw do
  resources :blogs, except: [:new, :edit]
  resources :posts, except: [:new, :edit]
  
  root :to => 'home#index'
end
