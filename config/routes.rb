TaQueue::Application.routes.draw do
  get "pages/index"

  root :to => "boards#index"

  resources :boards do
    get "new_show", :on => :member
    get "login"
    get "logout"
    post "logout"
    post "login_user"
    resources :tas
    resources :students do
      get "ta_accept", :on => :member
      get "ta_remove", :on => :member
    end
    resource :queue, :only => [:show, :update] do
      get "enter_queue"
      get "exit_queue"
    end
  end

  resources :tas
  resources :students do
    get "ta_accept", :on => :member
    get "ta_remove", :on => :member
  end

  namespace :admin do
    resources :queues
  end

  resource :queue, :only => [:show, :update] do
    get "enter_queue"
    get "exit_queue"
  end

  match "/chats" => "chats#receive", via: :post

end
