require 'spec_helper'

describe QueuesController do
  before :all do
  end

  after :all do
  end

  before :each do
    @school = Factory.create(:school)
    @instructor = @school.instructors.create!(Factory.attributes_for(:instructor))
    @queue = @instructor.queues.create!(Factory.attributes_for(:school_queue))
    @ta = @queue.tas.create!(Factory.attributes_for(:ta))
    @student = @queue.students.create!(Factory.attributes_for(:student))
    @student.in_queue = nil
    @student.save!
    set_api_headers
  end

  after :each do
    @school.destroy
  end

  describe "API" do
    it "update" do
      authenticate @ta

      @queue.frozen.should == false

      put :update, :queue => { :frozen => true }

      @queue.reload

      @queue.frozen.should == true

      response.code.should == "204"
    end

    it "show" do
      authenticate @ta
      3.times do
        @queue.tas.create!(Factory.attributes_for(:ta))
      end

      5.times do
        @queue.students.create!(Factory.attributes_for(:student))
      end

      7.times do
        @queue.students.create!(Factory.attributes_for(:student).merge!( :in_queue => DateTime.now ))
      end

      ta = @queue.tas.first

      ta.accept_student! @student


      get :show

      response.code.should == "200"
      
      res_hash = decode response.body


      res_hash.count.should == 6

      res_hash['frozen'].should_not be_nil
      res_hash['active'].should_not be_nil
      res_hash['is_question_based'].should_not be_nil
      res_hash['students'].should_not be_nil
      res_hash['status'].should_not be_nil
      res_hash['tas'].should_not be_nil

      # The 12 created above, and one in the before :each block
      res_hash['students'].count.should == 13
      res_hash['tas'].count.should == 4 # the extra is due to the ta created in the before :each block

      res_hash['tas'].each do |_ta|
        _ta['student']['id'].should == @queue.students.first.id.to_s if _ta['id'] == ta.id.to_s
      end
    end

    it "removes all students from the queue when going inactive" do
      authenticate @ta
      @queue.students.destroy_all

      @queue.active.should == true

      2.times do
        student = @queue.students.create!(Factory.attributes_for(:student))
        student.enter_queue!
      end

      @queue.students.in_queue.count.should == 2

      put :update, :queue => { :active => false }

      @queue.students(true).in_queue.count.should == 0

    end

    it "students should come back in the order they joined the queue" do
      @queue.students.destroy_all
      @queue.tas.destroy_all

      time = DateTime.now
      # Order should be 2, 5, 0, 1, 3, 4
      order = {}

      stud = @queue.students.create!(Factory.attributes_for(:student).merge( :in_queue => time + 2.seconds ))
      order["2"] = stud.id.to_s
      stud = @queue.students.create!(Factory.attributes_for(:student).merge( :in_queue => time + 3.seconds ))
      order["3"] = stud.id.to_s
      stud = @queue.students.create!(Factory.attributes_for(:student).merge( :in_queue => time ))
      order["0"] = stud.id.to_s
      stud = @queue.students.create!(Factory.attributes_for(:student).merge( :in_queue => time + 4.seconds ))
      order["4"] = stud.id.to_s
      stud = @queue.students.create!(Factory.attributes_for(:student).merge( :in_queue => time + 5.seconds ))
      order["5"] = stud.id.to_s
      stud = @queue.students.create!(Factory.attributes_for(:student).merge( :in_queue => time + 1.second  ))
      order["1"] = stud.id.to_s

      authenticate stud

      get :show

      response.code.should == "200"
      
      res = decode response.body

      res['students'].count.should == 6

      @queue.reload

      students = @queue.students.to_a

      students.each_index do |i|
        students[i].id.to_s.should == order[i.to_s].to_s
      end
    end
  end

  describe "actions" do
    it "should allow student to enter queue" do
      authenticate @student

      get :enter_queue

      response.code.should == "200" 

      res_hash = decode response.body

      @student.reload

      @student.in_queue.should_not be_nil
      res_hash['students'][0]['username'].should == @student.username
    end

    it "should allow student to enter queue with question" do
      authenticate @student

      @student.save!

      @queue.is_question_based = true
      @queue.save!

      question = "Who's your daddy?"

      get :enter_queue, :question => question

      response.code.should == "200" 

      res_hash = decode response.body

      @student.reload

      @student.question.should == question

      @student.in_queue.should_not be_nil
      res_hash['students'][0]['username'].should == @student.username
    end

    it "should not allow student to enter queue without question if question_based" do
      authenticate @student

      @queue.is_question_based = true

      @queue.save!

      get :enter_queue

      response.code.should == "422" 

      @student.reload

      @student.in_queue.should be_nil
    end

    it "should allow student to exit queue" do
      authenticate @student

      get :exit_queue

      response.code.should == "200"

      res_hash = decode response.body

      @student.reload

      @student.in_queue.should be_nil

      res_hash['students'].count.should == 1
    end

    it "should accept the next student if the student being helped dequeues themselves" do
      @ta.student.should be_nil
      authenticate @student

      other_student = @queue.students.create!(Factory.attributes_for(:student))
      @student.enter_queue!
      other_student.enter_queue!

      @ta.accept_student! @student

      @ta.student.should == @student
      @student.reload
      @student.ta.should == @ta

      other_student.in_queue = DateTime.now
      other_student.save!

      get :exit_queue

      @ta = Ta.find(@ta.id)

      @student.reload

      @student.ta.should == nil

      @ta.student.should == other_student
    end

    it "should not throw exception if the student being helped dequeues and no one else is in the queue" do
      @ta.student.should be_nil
      authenticate @student

      @student.enter_queue!

      @ta.accept_student! @student

      @ta.student.should == @student
      @student.reload
      @student.ta.should == @ta

      get :exit_queue

      @ta.reload
      @student.reload

      @ta.student.should be_nil

      @student.ta.should be_nil
    end

  end


  describe "Error validation" do
    it "receives proper validation errors" do
      authenticate @student
      authenticate @ta

      @queue.frozen = false
      @queue.save!

      put :update, :queue => { :frozen => "hello" }

      response.code.should == "422"

      res = decode response.body

      res['errors']['frozen'].should_not be_nil
    end

    it "Doesn't respond to enter_queue when frozen" do
      @queue.frozen = true
      @queue.save!

      authenticate @student

      get :enter_queue

      response.code.should == "403"

      res = decode response.body

      res['error'].should_not be_nil

      @student.reload
      @student.in_queue.should == nil
    end

    it "doesn't respond to enter_queue when deactivated" do
      authenticate @student
      
      @queue.active = false 
      @queue.save!

      get :enter_queue

      response.code.should == "403"
    end

    it "doesn't respond to exit_queue when deactivated" do
      authenticate @student
      
      @queue.active = false 
      @queue.save!

      get :exit_queue

      response.code.should == "403"
    end
  end

  describe "authentication" do
    it "show should pass with ta authentication" do
      authenticate @ta

      get :show

      response.code.should == "200"
    end

    it "show should pass with student authentication" do
      authenticate @student

      get :show

      response.code.should == "200"
    end

    it "show should fail on no authentication" do
      get :show

      response.code.should == "401"
    end

    it "update should succeed on ta authentication" do
      authenticate @ta
      @queue.frozen.should == false

      put :update, :queue => { :frozen => true }

      response.code.should == "204"

      @queue.reload

      @queue.frozen.should == true
    end

    it "update should fail on student authentication" do
      authenticate @student
      @queue.frozen.should == false

      put :update, :queue => { :frozen => true }

      response.code.should == "401"

      @queue.reload

      @queue.frozen.should == false
    end

    it "update should fail on no authentication" do
      @queue.frozen.should == false
      put :update, :queue => { :frozen => true }

      response.code.should == "401"

      @queue.reload

      @queue.frozen.should == false
    end
  end
end
