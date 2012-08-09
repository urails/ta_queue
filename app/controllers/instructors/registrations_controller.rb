class Instructors::RegistrationsController < Devise::RegistrationsController
  def after_update_path_for instructor
    instructors_dashboard_path
  end
end

