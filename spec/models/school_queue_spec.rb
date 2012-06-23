require 'spec_helper'

describe SchoolQueue do
  before :each do
    @school = create :school
    @instructor = @school.instructors.create(attributes_for(:instructor))
    @queue = @instructor.queues.create(attributes_for(:school_queue))
  end

  describe "when activating/deactivating" do
    it "unfreezes the queue when deactivating" do
      @queue.frozen = true
      @queue.active = false
      @queue.save

      @queue.reload

      @queue.frozen.should == false
      @queue.active = true
      @queue.save

      @queue.reload

      @queue.frozen.should
    end
  end
  
end
