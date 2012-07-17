class QueuesController < ApplicationController
  before_filter :authenticate_student!, only: [:enter_queue, :exit_queue]
  before_filter :authenticate!, only: [:show]
  before_filter :authenticate_ta!, only: [:update]
  before_filter :forward_if_logged_in, only: [:login]
  before_filter :get_queue
  before_filter :check_frozen, only: [:enter_queue]
  before_filter :check_active, only: [:enter_queue, :exit_queue]

  #after_filter :push_notify!, :only => [:update, :enter_queue, :exit_queue]

  respond_to :json, :html

  def show
    respond_with @queue
  end

  def login
    @ta = Ta.new
    @student = Student.new
  end

  def update
    @queue.update_attributes(queue_params)
    push_notify!
    respond_with @queue
  end

  def enter_queue
    if @queue.is_question_based
      render json: { errors: ["You must enter a question to enter the queue"] }, status: 422  and return if params[:question].blank?
    end
    current_user.question = params[:question]
    current_user.enter_queue!
    push_notify!
    respond_with @queue, template: "queues/show"
  end

  def exit_queue
    ta = current_user.ta

    # We need to grab out this flag before the user exits the queue
    should_accept_next = false
    should_accept_next = true if current_user.ta 

    current_user.exit_queue!

    # If when exiting the queue, the student was being helped by a TA, automatically
    # accept the next student
    # TODO: Make this current.
    #ta.accept_next_student if should_accept_next

    push_notify!

    respond_with @queue, template: "queues/show"
  end

  def ios
    @queue = QueueUser.where( token: params[:token] ).first.queue
  end
  
  private

    def check_frozen
      if @queue.frozen
        respond_with do |f|
          render template: "queues/error_frozen", :status => 403 and return
        end
      end
    end

    def queue_params
      params[:queue].slice :active, :frozen, :status
    end

    def forward_if_logged_in
      if current_user
        redirect_to queue_path
      end
    end
end
