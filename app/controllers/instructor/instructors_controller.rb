class Instructor::InstructorsController < InstructorController
  def dashboard

  end

  def new

  end

  def login
    @instructor = Instructor.new
  end
end
