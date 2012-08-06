class Instructors::InstructorsController < InstructorsController
  before_filter :authenticate_instructor!, only: [:dashboard]

  def dashboard
    @instructor = current_instructor
    @queue = @instructor.queues.first
    redirect_to edit_instructors_queue_path(@queue) if @queue
  end

  def new
    @instructor = Instructor.new
  end

  def login
    @instructor = Instructor.new
  end
end
