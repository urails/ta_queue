class Instructors::InstructorsController < InstructorsController
  before_filter :authenticate_instructor!, only: [:dashboard]

  def dashboard
    @instructor = current_instructor
  end

  def new
    @instructor = Instructor.new
  end

  def login
    @instructor = Instructor.new
  end
end
