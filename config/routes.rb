TaQueue::Application.routes.draw do
  devise_for :instructors

  match "learn_more" => "pages#learn_more"

  namespace :instructor do
    match "new" => "instructors#new"
    match "login" => "instructors#login"
    root :to => "instructors#dashboard"
    resources :queues, :only => [:new, :edit, :update, :create, :show]
  end

  devise_scope :instructor do
    get "/instructors/sign_in", :to => "instructor/instructors#login"
  end

  root :to => "schools#index"

  match "schools/:school/:instructor/:queue/login" => "queues#login", as: :queue_login
  match "schools/:school/:instructor/:queue/students" => "students#create", as: :create_student, via: :post
  match "schools/:school/:instructor/:queue/tas" => "tas#create", as: :create_ta, via: :post

  resources :schools, :only => [:index]

  resources :tas, :only => [:index, :show, :update, :destroy]
  resources :students, :only => [:index, :show, :update, :destroy] do
    get "ta_accept", :on => :member
    get "ta_remove", :on => :member
  end

  resource :queue, :only => [:show, :update] do
    get "new_show"
    get "enter_queue"
    get "exit_queue"
  end

  match "/queue/ios/:token" => "queues#ios"

  match "/chats" => "chats#receive", via: :post

end
