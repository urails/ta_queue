TaQueue::Application.routes.draw do
  get "pages/index"

  root :to => "schools#index"

  match "schools/:school/:instructor/:queue/login" => "queues#login", as: :queue_login
  match "schools/:school/:instructor/:queue/students" => "students#create", as: :create_student, via: :post
  match "schools/:school/:instructor/:queue/tas" => "students#create", as: :create_ta, via: :post

  resources :schools, :only => [:index]

  resources :tas, :only => [:index, :show, :update, :destroy]
  resources :students, :only => [:index, :show, :update, :destroy] do
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
