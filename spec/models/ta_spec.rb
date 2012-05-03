require 'spec_helper'

describe Ta do
  before :each do
    @school = Factory.create :school
    @instructor = @school.instructors.create(Factory.attributes_for(:instructor))
    @queue = @instructor.queues.create(Factory.attributes_for(:school_queue))
    @ta = @queue.tas.create Factory.attributes_for(:ta)
    @student = @queue.students.create Factory.attributes_for(:student)
  end

  it "properly accepts new students, setting all the proper attributes" do
      @queue.students.destroy_all

      10.times do |i|
        @queue.students.create!(Factory.attributes_for(:student).merge(:in_queue => DateTime.now + i.seconds))
      end

      students = @queue.students.in_queue.to_a

      students.count.times do |i|
        current_student = students[i]
        
        @ta.accept_student! current_student

        if i != 0
          prev_student = Student.find(students[i - 1].id)
          prev_student.in_queue.should be_nil
          prev_student.ta.should be_nil
        end

        current_student = Student.find(current_student.id)
        current_student.ta.should == @ta
        current_student.in_queue.should_not be_nil

        @ta.student.should == current_student

        new_students = @queue.students.in_queue.to_a

        new_students.count.should == 10 - i
      end
  end
end
