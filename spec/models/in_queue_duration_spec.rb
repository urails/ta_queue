require 'spec_helper'

describe InQueueDuration do
  before :each do
    @iqd = InQueueDuration.new
    @iqd.save
  end

  after :each do
    @iqd.destroy
  end

  describe "time_in_queue" do
    it "computes proper time_in_queue (seconds)" do
      @iqd.enter_time = DateTime.now
      @iqd.exit_time = @iqd.enter_time + 12.seconds

      @iqd.time_in_queue.should == 12.0
    end

    it "computes proper time_in_queue (minutes)" do
      @iqd.enter_time = DateTime.now
      @iqd.exit_time = @iqd.enter_time + 12.seconds

      @iqd.time_in_queue(:minutes).should == 12.0 / 60
    end

    it "computes proper time_in_queue (hours)" do
      @iqd.enter_time = DateTime.now
      @iqd.exit_time = @iqd.enter_time + 12.seconds

      @iqd.time_in_queue(:hours).should == (12.0 / 60) / 60
    end

    it "throws exception with no enter or exit time" do
      passed = false
      begin
        @iqd.time_in_queue
      rescue Exception => e
        passed = true
      end

      passed.should == true
    end

    it "throws exception with no exit time" do
      passed = false

      @iqd.enter_time = DateTime.now

      begin
        @iqd.time_in_queue
      rescue Exception => e
        passed = true
      end

      passed.should == true
    end

    it "throws exception with no enter time" do
      passed = false

      @iqd.exit_time = DateTime.now

      begin
        @iqd.time_in_queue
      rescue Exception => e
        passed = true
      end

      passed.should == true
    end

    it "does NOT throw exception with both enter and exit time" do
      passed = true

      @iqd.exit_time = DateTime.now
      @iqd.enter_time = DateTime.now

      begin
        @iqd.time_in_queue
      rescue
        passed = false
      end

      passed.should == true
    end
  end

end
