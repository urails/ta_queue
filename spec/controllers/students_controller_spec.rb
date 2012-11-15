require 'spec_helper'

describe StudentsController do

  before :each do
    set_api_headers
  end

  before :all do
    @school = create :school
    @instructor = @school.instructors.create!(attributes_for(:instructor))
    @queue = @instructor.queues.create!(attributes_for(:school_queue))
    @full_student_hash = attributes_for :student
    @queue_hash = { :school => @school.abbreviation, :instructor => @instructor.username, :queue => @queue.class_number }
  end

  after :all do
    @school.destroy
  end

  describe "CRUD student" do
    it "successfully creates a student" do
      post :create, { :student => @full_student_hash }.merge(@queue_hash)

      response.code.should == "201"

      res_hash = ActiveSupport::JSON.decode(response.body)

      res_hash.count.should == 4

      res_hash['username'].should == @full_student_hash[:username]
      res_hash['location'].should == @full_student_hash[:location]
      res_hash['id'].should_not be_nil
      res_hash['token'].should_not be_nil

      @full_student_hash.merge!({ :id => res_hash['id'], :token => res_hash['token']})
    end

    it "receives proper validation errors" do
      student = attributes_for :student
      student[:username] = ""
    	post :create, { :student => student }.merge(@queue_hash)
    	
    	response.code.should == "422"

      res = decode response.body

      res['errors'][0].include?("Username").should == true
    end
    
    it "allows same username with different location" do
      student_1 = attributes_for :student
      student_2 = attributes_for :student
      student_1[:username] = "doesn't matter"
      student_2[:username] = "doesn't matter"
      
      post :create, { :student => student_1 }.merge(@queue_hash)

      response.code.should == "201"

      post :create, { :student => student_2 }.merge(@queue_hash)

      response.code.should == "201"
    end

    it "succeeds with same username and location in different queues" do
      student_1 = attributes_for :student
      student_2 = attributes_for :student
      student_2[:username] = student_1[:username]
      student_2[:location] = student_1[:location]

      queue2 = @instructor.queues.create!(attributes_for(:school_queue))
      queue2.students.create!(student_2)

      queue_hash2 = { 
        :school => @school.abbreviation, 
        :instructor => @instructor.username, 
        :queue => queue2.class_number 
      }
      
      post :create, { :student => student_1 }.merge(@queue_hash)

      response.code.should == "201"
    end

    it "fails with same username and location in same queue" do
      student_1 = attributes_for :student
      student_2 = attributes_for :student
      student_2[:username] = student_1[:username]
      student_2[:location] = student_1[:location]
      
      post :create, { :student => student_1 }.merge(@queue_hash)

      response.code.should == "201"

      post :create, { :student => student_2 }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res["errors"].should_not be_nil
    end
    
    it "successfully reads a student" do
      authenticate QueueUser.where(:_id => @full_student_hash[:id]).first
      get :show, { :id => @full_student_hash[:id] }

      response.code.should == "200"

      res_hash = ActiveSupport::JSON.decode(response.body)

      res_hash.count.should == 6

      res_hash['username'].should == @full_student_hash[:username]
      res_hash['location'].should == @full_student_hash[:location]
      res_hash['id'].should == @full_student_hash[:id]
      res_hash['in_queue'].to_s.should == "false"
      res_hash['ta_id'].should be_nil
      res_hash['question'].should be_nil
    end

    it "successfully destroys the student" do
      authenticate QueueUser.where(:_id => @full_student_hash[:id]).first
      delete :destroy, { :id => @full_student_hash[:id] }

      response.code.should == "204"

      QueueUser.where(:_id => @full_student_hash[:id]).first.should be_nil
    end
  end

  describe "authentication" do
    before :each do
      @student = @queue.students.create!(attributes_for(:student))
      @ta = @queue.tas.create!(attributes_for(:ta))
    end

    after :each do
      @student.destroy
    end

    it "fails when student tries to change another student's state" do
      student_1 = @queue.students.create!(attributes_for(:student))
      student_2 = @queue.students.create!(attributes_for(:student))
      authenticate student_2

      put :update, { :student => { :username => "it doesn't matter cause this should fail" }, :id => student_1.id.to_s }

      response.code.should == "401"
    end

    it "fails reading a student w/o credentials" do
      get :show, { :id => @student.id }

      response.code.should == "401"
    end

    it "fails updating w/o credentials" do
      put :update, { :student => { :in_queue => true}, :id => @student.id }
      response.code.should ==  "401"
    end

    it "fails destroying without authorization" do
      delete :destroy, { :id => @student.id }
      response.code.should == "401"
    end

    it "should reject ta_accept from a student" do
      authenticate @student

      get :ta_accept, { :id => @student.id }

      response.code.should == "401"
    end

    it "should reject ta_accept without authentication" do
      get :ta_accept, { :id => @student.id }

      response.code.should == "401"
    end

    it "ta_remove should reject no authentication" do
      get :ta_remove, { :id => @student.id }

      response.code.should == "401"
    end

    it "ta_remove should reject student authentication" do
      authenticate @student
      get :ta_remove, { :id => @student.id }

      response.code.should == "401"
    end

    it "ta_remove should succeed with ta authentication" do
      authenticate @ta
      get :ta_remove, { :id => @student.id }

      response.code.should == "200"
    end
  end

  describe "API" do
    
    it "index returns a list of students" do
      @queue.queue_users.destroy_all

      5.times do
        @queue.students.create!(attributes_for(:student))
      end

      authenticate @queue.students(true).first

      get :index

      response.code.should == "200"

      res = decode response.body

      res.count.should == @queue.students.count
    end

    it "sends back the question if a TA is logged in" do
      ta = @queue.tas.create(attributes_for(:ta))
      student = @queue.students.create(attributes_for(:student))
      question = "Hello world, man"
      student.question = question
      student.save!

      authenticate ta

      get :show, :id => student.id

      res = decode response.body

      res["question"].should == question
    end

    it "doesn't send back the question if a student is logged in" do
      ta = @queue.tas.create(attributes_for(:ta))
      student = @queue.students.create(attributes_for(:student))
      student2 = @queue.students.create(attributes_for(:student))
      question = "Hello world, man"
      student.question = question
      student.save!

      # Students can see their own question, so we need to test this with
      # another student making the request.
      authenticate student2

      get :show, :id => student.id

      res = decode response.body

      res["question"].should be_nil
    end

  end

  describe "student actions" do
    before :each do
      @full_student_hash = attributes_for :student
      @ta = @queue.tas.create!(attributes_for :ta )
      @student = @queue.students.create!(@full_student_hash)
    end

    after :each do
      Ta.destroy_all
      Student.destroy_all
    end

    it "should successfully be accepted by TA" do
      authenticate @ta 

      @ta.student.should be_nil

      get :ta_accept, { :id => @student.id }

      response.code.should == "200"

      @ta.reload

      @ta.student.should_not be_nil
      @ta.student.id.should == @student.id

      @student.reload
      @student.ta.should_not be_nil
      @student.ta.id.should == @ta.id
    end

    it "should properly detach the current student when accepting a new student" do
      authenticate @ta

      @ta.student = @student
      @ta.save

      @second_student = @queue.students.create!(attributes_for(:student))

      get :ta_accept, { :id => @second_student.id }

      response.code.should == "200"

      @ta.reload
      @ta.student.should == @second_student

      @student.reload
      @student.ta.should be_nil
      @student.in_queue.should be_nil
    end

    it "ta_remove should properly remove a student from the queue" do
      authenticate @ta
      @student.in_queue = DateTime.now
      @student.save.should == true
      get :ta_remove, { :id => @student.id }

      response.code.should == "200"

      @student.reload

      @student.in_queue.should be_nil
      @student.ta.should be_nil
    end

    it "puts back a student with ta_putback" do
      authenticate @ta
      @student.enter_queue!
      @ta.accept_student! @student

      get :ta_putback, id: @student.id

      response.code.should == "200"

      @student.reload
      @student.ta.should be_nil
      @student.in_queue.should_not be_nil
    end


  end

  describe "Errors" do
    it "create fails creating a student with a name longer than 40 characters" do
      stud = attributes_for :student
      stud[:username] = "a" * 41
      post :create, { :student => stud }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res['errors'].should_not be_nil
    end
    
    it "create succeeds creating a student with a name longer than 40 characters" do
      stud = attributes_for :student
      stud[:username] = "a" * 40
      post :create, { :student => stud }.merge(@queue_hash)

      response.code.should == "201"
    end

    it "fails creating a student with a location longer than 20 characters" do
      stud = attributes_for :student
      stud[:location] = "a" * 21
      post :create, { :student => stud }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res['errors'].should_not be_nil

    end

    it "create fails if username is 'username'" do
      stud = attributes_for :student
      stud[:username] = "username"

      post :create, { :student => stud }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res['errors'].should_not be_nil
    end

    it "create fails if username is 'name'" do
      stud = attributes_for :student
      stud[:username] = "name"

      post :create, { :student => stud }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res['errors'].should_not be_nil
    end

    it "create fails if location is 'location'" do
      stud = attributes_for :student
      stud['location'] = "location"

      post :create, { :student => stud }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res['errors'].should_not be_nil
    end

    it "fails if trying 'show' action on non-existant student" do
      authenticate @queue.students.create(@full_student_hash)

      get :show, { :id => "hello" }

      response.code.should == "401"
    end

    it "create succeeds creating a student with a location longer than 20 characters" do
      stud = attributes_for :student
      stud[:location] = "a" * 20
      post :create, { :student => stud }.merge(@queue_hash)

      response.code.should == "201"
    end
  end

end
