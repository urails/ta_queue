class Instructor::InstructorsController < ApplicationController
  def dashboard

  end

  def new

  end

  def login
    @instructor = Instructor.new
  end
end
