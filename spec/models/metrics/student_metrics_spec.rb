require 'spec_helper'

describe Student do
  before(:each) do
    InQueueDuration.destroy_all
    @school = Factory.create :school
    @instructor = @school.instructors.create(Factory.attributes_for(:instructor))
    @queue = @instructor.queues.create(Factory.attributes_for(:school_queue))
    @student = @queue.students.create( Factory.attributes_for(:student) )
  end

  after (:each) { @student.destroy }

  describe "in_queue_duration" do
    it "new durations are created everytime a student enters the queue" do
      @student.enter_queue!
      InQueueDuration.count.should == 1
      @student.exit_queue!

      @student.enter_queue!
      InQueueDuration.count.should == 2
      @student.exit_queue!

      InQueueDuration.count.should == 3
    end

    it "sets enter_time for in_queue_duration on entering queue" do
      @student.enter_queue!
      @student.in_queue_duration(true).enter_time.should_not be_nil
    end

    it "sets exit_time for in_queue_duration on exiting queue" do
      @student.enter_queue!
      iqd = @student.in_queue_duration(true)
      @student.exit_queue!
      InQueueDuration.find(iqd.id).exit_time.should_not be_nil
    end

    it "sets was_helped to false if a student isn't being helped" do
      @student.enter_queue!
      iqd = @student.in_queue_duration(true)
      @student.exit_queue!
      InQueueDuration.find(iqd.id).was_helped.should == false
    end

    it "sets was_helped to true if TA was helping them" do
      @student.enter_queue!

      ta = @queue.tas.create(Factory.attributes_for(:ta))
      ta.accept_student! @student
      iqd = @student.in_queue_duration
      @student.exit_queue!
      InQueueDuration.find(iqd.id).was_helped.should == true

    end
  end
end

