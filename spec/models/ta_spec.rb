require 'spec_helper'

describe Ta do
  before :each do
    @school = create :school
    @instructor = @school.instructors.create(attributes_for(:instructor))
    @queue = @instructor.queues.create(attributes_for(:school_queue))
    @ta = @queue.tas.create attributes_for(:ta)
    @student = @queue.students.create attributes_for(:student)
  end

  after :each do
    @school.destroy
  end

  it "properly accepts new students, setting all the proper attributes" do
      @queue.students.destroy_all

      10.times do |i|
        @queue.students.create!(attributes_for(:student).merge(:in_queue => DateTime.now + i.seconds))
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

  it "removes student when queue becomes inactive" do
    @ta.student = @student
    @ta.save
    @student.save

    @ta.reload
    @ta.student.should == @student

    @queue.active = false
    @queue.save

    @ta.reload
    @ta.student.should == nil
  end
end
