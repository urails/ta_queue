class SchoolsController < ApplicationController
  respond_to :json, :html

  def index
    @schools = School.all
    
    respond_with @schools
  end
end
