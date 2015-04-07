TaQueue::Application.routes.draw do
  devise_for :instructors, controllers: { sessions: 'instructors/sessions',
                                          registrations: 'instructors/registrations' }

  match "learn_more" => "pages#learn_more"
  match "support" => "pages#support"

  namespace :instructors do
    match "new" => "instructors#new"
    match "login" => "instructors#login"
    match "instructor_root" => "instructors#dashboard"
    root :to => "instructors#dashboard", as: :dashboard
    resources :queues, :only => [:new, :edit, :update, :create, :show, :destroy]
  end

  root :to => "schools#index"

  match "schools/:school/:instructor/:queue/login" => "queues#login", as: :queue_login
  match "schools/:school/:instructor/:queue/students" => "students#create", as: :create_student, via: :post
  match "schools/:school/:instructor/:queue/tas" => "tas#create", as: :create_ta, via: :post

  resources :schools, :only => [:index]

  resources :tas, :only => [:index, :show, :update, :destroy]
  resources :students, :only => [:index, :show, :update, :destroy] do
    # All `get` endpoints should be removed eventually to prevent CSRF
    # Need to wait for all clients to propagate. See: https://github.com/urails/ta_queue/issues/87
    get "ta_accept", on: :member
    get "ta_remove", on: :member
    get "ta_putback", on: :member
    post "ta_accept", on: :member
    post "ta_remove", on: :member
    post "ta_putback", on: :member
  end

  resource :queue, :only => [:show, :update] do
    get "new_show"
    get "enter_queue"
    get "exit_queue"
    post "new_show"
    post "enter_queue"
    post "exit_queue"
  end

  match "/queue/ios" => "queues#ios"

  match "/chats" => "chats#receive", via: :post

end
