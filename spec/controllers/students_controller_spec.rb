require 'spec_helper'

describe StudentsController do

  before :each do
    set_api_headers
  end


    before :all do
      Board.destroy_all
      Student.destroy_all 
      @board = Factory.create :board
      @full_student_hash = Factory.attributes_for :student
    end

    after :all do
      @board.destroy
    end

  describe "CRUD student" do
    it "successfully creates a student" do
      post :create, { :student => @full_student_hash, :board_id => @board.title }

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
      student = Factory.attributes_for :student
      student[:username] = ""
    	post :create, { :student => student, :board_id => @board.title }
    	
    	response.code.should == "422"

      res = decode response.body

      res['username'].should_not be_nil
    end
    
    it "allows same username with different location" do
      student_1 = Factory.attributes_for :student
      student_2 = Factory.attributes_for :student
      student_1[:username] = "doesn't matter"
      student_2[:username] = "doesn't matter"
      
      post :create, { :student => student_1, :board_id => @board.title }

      response.code.should == "201"

      post :create, { :student => student_2, :board_id => @board.title }

      response.code.should == "201"
    end

    it "fails with same username and location" do
      student_1 = Factory.attributes_for :student
      student_2 = Factory.attributes_for :student
      student_2[:username] = student_1[:username]
      student_2[:location] = student_1[:location]
      
      post :create, { :student => student_1, :board_id => @board.title }

      response.code.should == "201"

      post :create, { :student => student_2, :board_id => @board.title }

      response.code.should == "422"

      res = decode response.body

      res["username"].should_not be_nil
    end
    
    it "successfully reads a student" do
      authenticate QueueUser.where(:_id => @full_student_hash[:id]).first
      get :show, { :id => @full_student_hash[:id], :board_id => @board.title }

      response.code.should == "200"

      res_hash = ActiveSupport::JSON.decode(response.body)

      res_hash.count.should == 4

      res_hash['username'].should == @full_student_hash[:username]
      res_hash['location'].should == @full_student_hash[:location]
      res_hash['id'].should == @full_student_hash[:id]
      res_hash['in_queue'].to_s.should == "false"
    end

    it "successfully destroys the student" do
      authenticate QueueUser.where(:_id => @full_student_hash[:id]).first
      delete :destroy, { :board_id => @board.title, :id => @full_student_hash[:id] }

      response.code.should == "200"

      QueueUser.where(:_id => @full_student_hash[:id]).first.should be_nil
    end
  end

  describe "authentication" do
    before :each do
      @student = @board.students.create!(Factory.attributes_for(:student))
      @ta = @board.tas.create!(Factory.attributes_for(:ta))
    end

    after :each do
      @student.destroy
    end

    it "fails when student tries to change another student's state" do
      student_1 = @board.students.create!(Factory.attributes_for(:student))
      student_2 = @board.students.create!(Factory.attributes_for(:student))
      authenticate student_2

      put :update, { :student => { :username => "it doesn't matter cause this should fail" }, :board_id => @board.title, :id => student_1.id.to_s }

      response.code.should == "401"
    end

    it "fails reading a student w/o credentials" do
      get :show, { :id => @student.id, :board_id => @board.title }

      response.code.should == "401"
    end

    it "fails updating w/o credentials" do
      put :update, { :student => { :in_queue => true}, :id => @student.id, :board_id => @board.title }
      response.code.should ==  "401"
    end

    it "fails destroying without authorization" do
      delete :destroy, { :board_id => @board.title, :id => @student.id }
      response.code.should == "401"
    end

    it "should reject ta_accept from a student" do
      authenticate @student

      get :ta_accept, { :board_id => @board.title, :id => @student.id }

      response.code.should == "401"
    end

    it "should reject ta_accept without authentication" do
      get :ta_accept, { :board_id => @board.title, :id => @student.id }

      response.code.should == "401"
    end

    it "ta_remove should reject no authentication" do
      get :ta_remove, { :board_id => @board.title, :id => @student.id }

      response.code.should == "401"
    end

    it "ta_remove should reject student authentication" do
      authenticate @student
      get :ta_remove, { :board_id => @board.title, :id => @student.id }

      response.code.should == "401"
    end

    it "ta_remove should succeed with ta authentication" do
      authenticate @ta
      get :ta_remove, { :board_id => @board.title, :id => @student.id }

      response.code.should == "200"
    end
  end

  describe "API" do
    
    it "index returns a list of students" do
      board = Factory.create :board

      5.times do
        board.students.create!(Factory.attributes_for(:student))
      end

      authenticate board.students.first

      get :index, { :board_id => board.title }
      
      response.code.should == "200"

      res = decode response.body

      res.count.should == board.students.count
      board.destroy
    end

    it "show" do
      student = @board.students.create!(Factory.attributes_for(:student))

      authenticate student

      get :show, { :board_id => @board.title, :id => student.id.to_s }

      response.code.should == "200"

      res = decode response.body

      res.count.should == 4
      res['id'].should_not be_nil
      res['username'].should_not be_nil
      res['location'].should_not be_nil
      res['in_queue'].should_not be_nil
    end

  end

  describe "student actions" do
    before :each do
      @full_student_hash = Factory.attributes_for :student
      @ta = @board.tas.create!(Factory.attributes_for :ta )
      @student = @board.students.create!(@full_student_hash)
    end

    after :each do
      Ta.destroy_all
      Student.destroy_all
    end

    it "should successfully be accepted by TA" do
      authenticate @ta 

      @ta.student.should be_nil

      get :ta_accept, { :board_id => @board.title, :id => @student.id }

      response.code.should == "200"

      ta = Ta.find(@ta.id)

      ta.student.should_not be_nil
      ta.student.id.should == @student.id

      @student = Student.find(@student.id)
      @student.ta.should_not be_nil
      @student.ta.id.should == @ta.id
    end

    it "should properly detach the current student when accepting a new student" do
      authenticate @ta

      @ta.student = @student
      @ta.save

      @second_student = @board.students.create!(Factory.attributes_for :student)

      get :ta_accept, { :board_id => @board.title, :id => @second_student.id }

      response.code.should == "200"

      @ta = Ta.find(@ta.id)
      @ta.student.should == @second_student

      @student = Student.find(@student.id)
      @student.ta.should be_nil
      @student.in_queue.should be_nil
    end

    it "ta_remove should properly remove a student from the queue" do
      authenticate @ta
      @student.in_queue = DateTime.now
      @student.save.should == true
      get :ta_remove, { :board_id => @board.title, :id => @student.id }

      response.code.should == "200"

      @student = Student.find(@student.id)

      @student.in_queue.should be_nil
      @student.ta.should be_nil
    end


  end

  describe "Errors" do
    it "create fails creating a student with a name longer than 40 characters" do
      stud = Factory.attributes_for :student
      stud[:username] = "a" * 41
      post :create, { :board_id => @board.title, :student => stud }

      response.code.should == "422"

      res = decode response.body

      res['username'].should_not be_nil
    end
    
    it "create succeeds creating a student with a name longer than 40 characters" do
      stud = Factory.attributes_for :student
      stud[:username] = "a" * 40
      post :create, { :board_id => @board.title, :student => stud }

      response.code.should == "201"
    end

    it "fails creating a student with a location longer than 20 characters" do
      stud = Factory.attributes_for :student
      stud[:location] = "a" * 21
      post :create, { :board_id => @board.title, :student => stud }

      response.code.should == "422"

      res = decode response.body

      res['location'].should_not be_nil

    end

    it "create fails if username is 'username'" do
      stud = Factory.attributes_for :student
      stud[:username] = "username"

      post :create, { :board_id => @board.title, :student => stud }

      response.code.should == "422"

      res = decode response.body

      res['username'].should_not be_nil
    end

    it "create fails if username is 'name'" do
      stud = Factory.attributes_for :student
      stud[:username] = "name"

      post :create, { :board_id => @board.title, :student => stud }

      response.code.should == "422"

      res = decode response.body

      res['username'].should_not be_nil
    end

    it "create fails if location is 'location'" do
      stud = Factory.attributes_for :student
      stud['location'] = "location"

      post :create, { :board_id => @board.title, :student => stud }

      response.code.should == "422"

      res = decode response.body

      res['location'].should_not be_nil
    end

    it "fails if trying 'show' action on non-existant student" do
      authenticate @board.students.create(@full_student_hash)

      get :show, { :board_id => @board.title, :id => "hello" }

      res = decode response.body

      response.code.should == "422"

      res['error'].should_not be_nil
    end

    it "create succeeds creating a student with a location longer than 20 characters" do
      stud = Factory.attributes_for :student
      stud[:location] = "a" * 20
      post :create, { :board_id => @board.title, :student => stud }

      response.code.should == "201"
    end
  end

end
