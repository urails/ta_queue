class Instructor::InstructorsController < InstructorController
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
