require 'spec_helper'

describe Instructor do
  before :each do
    @school = create :school
    @instructor = @school.instructors.create!(attributes_for(:instructor))
  end

  describe "validations" do
    it "instructors with the same username are invalid" do
      instructor = @school.instructors.new(attributes_for(:instructor))
      instructor.username = @instructor.username
      instructor.save.should == false
      instructor.errors[:username].should_not be_nil
    end

    it "instructors with the same username, different school, are valid" do
      school = create :school
      instructor = school.instructors.new(attributes_for(:instructor))
      instructor.username = @instructor.username
      instructor.save.should == true
    end
  end
end
