class InstructorsController < ApplicationController

  def after_sign_in_path_for instructor
    instructors_dashboard_path
  end

end
