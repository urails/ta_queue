class StudentsController < ApplicationController
  before_filter :authenticate_current_student_or_ta!, :except => [:create, :ta_accept, :index]
  before_filter :authenticate_ta!, :only => [:ta_accept, :ta_remove]
  before_filter :authenticate!, :only => [:index]
  before_filter :get_queue
  before_filter :get_student, :except => [:index, :new, :create]

  #after_filter :push_notify!, [:create, :update, :destroy, :ta_accept, :ta_remove]

  respond_to :json
  respond_to :html, :only => [:create, :update]

  def show
    respond_with @student
  end

  def create 
    @student = @queue.students.new(params[:student])
    respond_with do |f|
      if @student.save
        sign_in_user @student
        @current_user = @student
        push_notify!
        f.html { redirect_to queue_path }
        f.json { render :json => { location: @student.location, token: @student.token, id: @student.id, username: @student.username }, :status => :created }
        f.xml  { render :xml => { token: @student.token, id: @student.id, username: @student.username }, :status => :created }
      else
        flash[:errors] = @student.errors.full_messages
        f.html { redirect_to build_queue_login_path(@queue, :student => true) }
        f.json { render :json => { errors: @student.errors.full_messages }, :status => :unprocessable_entity }
        f.xml  { render :xml  => { errors: @student.errors.full_messages }, :status => :unprocessable_entity }
      end
    end
  end

  def index
    @students = @queue.students
    if params[:in_queue]
      @students = @queue.students.in_queue
    end
    respond_with @students
  end

  def update
    @student.update_attributes(params[:student])
    push_notify!
    respond_with @student
  end

  def destroy
    @student.destroy
    sign_out_user @student
    push_notify!
    respond_with do |f|
      f.html { redirect_to build_queue_login_path @student.queue }
    end
  end

###### ACTIONS ######

  def ta_accept
    current_user.accept_student! @student
    push_notify!
    respond_with @student, :template => "students/show"
  end

  def ta_remove
    @student.exit_queue!
    push_notify!
    respond_with @student, :template => "students/show"
  end

  def ta_putback
    @student.putback!
    push_notify!
    respond_with @student, :template => "students/show"
  end

###### PRIVATE ######

  private

    def get_student
      @student ||= @queue.students.where(:_id => params[:id]).first
      if !@student
        render template: "shared/does_not_exist", :status => 422 and return
      end
    end

end
