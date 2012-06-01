require 'spec_helper'

describe Student do
  before :each do
    @school = create(:school)
    @instructor = @school.instructors.create!(attributes_for(:instructor))
    @queue = @instructor.queues.create!(attributes_for(:school_queue))
    @student = @queue.students.create!(attributes_for(:student))
    @ta = @queue.tas.create!(attributes_for(:ta))
  end

  after :each do
    @school.destroy
  end

  describe "InQueueDuration" do
    it "has one finished duration after enter and exit" do
      @student.enter_queue!
      @student.exit_queue!
      @queue.in_queue_durations.finished.count.should == 1
    end

    it "has two after enter, exit, enter, and destroy" do
      @student.enter_queue!
      @student.exit_queue!
      @student.enter_queue!

      @queue.in_queue_durations.finished.count.should == 1

      @student.destroy

      @queue.in_queue_durations.finished.count.should == 2
    end

    it "has one after enter, exit, destroy" do
      @student.enter_queue!
      @student.exit_queue!
      @student.destroy

      @queue.in_queue_durations.finished.count.should == 1
    end

    it "wasn't helped if no ta accepts them" do
      @student.enter_queue!
      @student.exit_queue!

      @queue.in_queue_durations.finished.first.was_helped.should == false
    end

    it "wasn't helped if no ta accepts them and they are destroyed" do
      @student.enter_queue!
      @student.destroy

      @queue.in_queue_durations.finished.first.was_helped.should == false
    end

    it "was helped if ta accepts them and exits queue" do
      @student.enter_queue!
      @ta.accept_student! @student

      @student.exit_queue!

      @queue.in_queue_durations.finished.first.was_helped.should == true
    end

    it "was helped if ta accepts them and is destroyed" do
      @student.enter_queue!
      @ta.accept_student! @student

      @student.destroy

      @queue.in_queue_durations.finished.first.was_helped.should == true
    end


  end

end
