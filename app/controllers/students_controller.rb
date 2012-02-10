class StudentsController < ApplicationController
  before_filter :get_board
  before_filter :get_student, :except => [:index, :new, :create]
  before_filter :authenticate_current_student_or_ta!, :except => [:create, :ta_accept, :index]
  before_filter :authenticate_ta!, :only => [:ta_accept, :ta_remove]
  before_filter :authenticate!, :only => [:index]

  #after_filter :push_notify!, [:create, :update, :destroy, :ta_accept, :ta_remove]

  respond_to :json
  respond_to :html, :only => [:create, :update]

  def show
    respond_with @student
  end

  def create 
    @student = @board.students.new(params[:student])
    respond_with do |f|
      if @student.save
        sign_in @student
        push_notify!
        f.html { redirect_to (board_path @board) }
        f.json { render :json => { location: @student.location, token: @student.token, id: @student.id, username: @student.username }, :status => :created }
        f.xml  { render :xml => { token: @student.token, id: @student.id, username: @student.username }, :status => :created }
      else
        flash[:errors] = @student.errors.full_messages
        f.html { redirect_to board_login_path(@board, :student => true) }
        f.json { render :json => @student.errors, :status => :unprocessable_entity }
        f.xml  { render :xml  => @student.errors, :status => :unprocessable_entity }
      end
    end
  end

  def index
    @students = @board.students
    respond_with @students
  end

  def update
    @student.update_attributes(params[:student])
    push_notify!
    respond_with @student
  end

  def destroy
    @student.destroy
    sign_out @student
    push_notify!
    respond_with do |f|
      f.html { redirect_to board_login_path @board }
    end
  end

###### ACTIONS ######

  def ta_accept
    current_user.accept_student! @student
    push_notify!
    respond_with @student, :template => "students/show.rabl"
  end

  def ta_remove
    @student.exit_queue!
    push_notify!
    respond_with @student, :template => "students/show.rabl"
  end

###### PRIVATE ######

  private

    def get_student
      @student ||= @board.students.where(:_id => params[:id]).first
      if !@student
        render template: "shared/does_not_exist.rabl", :status => 422
      end
    end
end
