require 'spec_helper'

describe SchoolsController do
  before :each do
    set_api_headers
  end

  describe "API" do
    it "index" do
      school = Factory.create :school
  
      instructor1 = school.instructors.create(Factory.attributes_for(:instructor))
      instructor2 = school.instructors.create(Factory.attributes_for(:instructor))

      queue1 = instructor1.queues.create(Factory.attributes_for(:school_queue))
      queue2 = instructor1.queues.create(Factory.attributes_for(:school_queue))
      queue3 = instructor2.queues.create(Factory.attributes_for(:school_queue))
      queue4 = instructor2.queues.create(Factory.attributes_for(:school_queue))

      get :index

      response.code.should == "200"

      res = decode response.body

      res.count.should == 1

      res.each do |school|
        school["name"].should_not be_nil
        school["abbreviation"].should_not be_nil
        school["instructors"].count.should == 2
        school["instructors"].each do |instructor|
          instructor["name"].should_not be_nil
          instructor["username"].should_not be_nil
          instructor["queues"].count.should == 2
          instructor["queues"].each do |queue|
            queue["active"].should_not be_nil
            queue["frozen"].should_not be_nil
            queue["class_number"].should_not be_nil
            queue["title"].should_not be_nil
          end
        end
      end

    end
  end
end
