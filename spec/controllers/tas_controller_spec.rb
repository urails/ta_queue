require 'spec_helper'

describe TasController do
  before :all do
    QueueUser.destroy_all
    @school = create :school
    @instructor = @school.instructors.create!(attributes_for(:instructor))
    @queue = @instructor.queues.create!(attributes_for(:school_queue))
    @full_ta_hash = { :username => "Bob" }
    @queue_hash = { school: @school.abbreviation, instructor: @instructor.username, queue: @queue.class_number }
  end

  after :all do
    @school.destroy
  end

  before :each do
    set_api_headers
  end

  describe "API" do
    before :each do
      @ta = @queue.tas.create!(attributes_for(:ta))
    end

    after :each do
      @ta.destroy
    end

    it "check escaped HTML" do
      authenticate @ta

      @ta.username = "<div>hello</div>"
      @ta.save

      get :show, { :id => @ta.id }

      response.code.should == "200"

      res = decode response.body

      res['username'].should == "&lt;div&gt;hello&lt;/div&gt;"
      
    end

    it "show w/out student" do
      authenticate @ta

      get :show, { :id => @ta.id }

      response.code.should == "200"

      res = decode response.body

      res['id'].should == @ta.id.to_s
      res['username'].should == @ta.username
      res['student'].should == nil
    end

    it "show with student" do
      student = @queue.students.create!(attributes_for(:student))
      @ta.student = student
      @ta.save

      @ta.student.should == student
      student.ta.should == @ta
      authenticate @ta

      get :show, { :id => @ta.id }

      response.code.should == "200"

      res = decode response.body

      res['id'].should == @ta.id.to_s
      res['username'].should == @ta.username
      res['student']['id'].should == @ta.student.id.to_s
      res['student']['username'].should == @ta.student.username
      res['student']['location'].should == @ta.student.location

      student.destroy
    end
  end

  describe "Errors" do
    before :each do
      @ta = @queue.tas.create!(attributes_for(:ta))
    end

    it "create" do
      post :create, { :ta => { :username => " ", :password => " " } }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res.count.should == 1

      res['errors'].should_not be_nil
    end

    it "create with invalid password" do
      post :create, { :ta => { :username => "blah", :password => "blah" } }.merge(@queue_hash)

      response.code.should == "422"

      res = decode response.body

      res.count.should == 1

      res['errors'].should_not be_nil
    end

    it "update" do
      authenticate @ta

      put :update, { :id => @ta.id.to_s, :ta => { :username => ""} }

      response.code.should == "422"

      res = decode response.body

      res.count.should == 1

      res['errors'].should_not be_nil
    end
  end

  describe "CRUD ta" do
    it "successfully creates a ta" do
      post :create, { :ta => @full_ta_hash.merge({ :password => @queue.password }) }.merge(@queue_hash)

      response.code.should == "201"

      res_hash = decode response.body

      res_hash.count.should == 3

      @full_ta_hash.merge!({ :id => res_hash['id'], :token => res_hash['token']})
    end

    it "increments login_count on successful login" do
      @queue.tas.destroy_all
      ta = @queue.tas.create!(@full_ta_hash.merge(password: @queue.password))
      ta.login_count.should == 1

      post :create, { :ta => @full_ta_hash.merge({ :password => @queue.password }) }.merge(@queue_hash)

      response.code.should == "201"

      ta = Ta.find(ta.id)
      ta.login_count.should == 2
    end

    it "fails to create a ta without proper password" do
      @queue.tas.destroy_all
      post :create, { :ta => @full_ta_hash.merge({ :password => "wrong_password" }) }.merge(@queue_hash)

      response.code.should == "422"
    end

    it "fails to create TA without proper password even if they are already logged in elsewhere" do
      ta_hash = attributes_for(:ta)
      @queue.tas.destroy_all
      @queue.tas.create!(ta_hash)
      post :create, { :ta => ta_hash.merge({ :password => "wrong_password" }) }.merge(@queue_hash)

      response.code.should == "422"
    end

    it "logs in a TA with same username in same queue" do
      ta_hash = attributes_for(:ta)
      @queue.tas.create!(ta_hash)
      post :create, { :ta => ta_hash.merge({ :password => @queue.password }) }.merge(@queue_hash)

      response.code.should == "201"
    end

    it "successfully creates a ta with same username in different queue" do
      queue2 = @instructor.queues.create!(attributes_for(:school_queue))

      ta_hash = attributes_for(:ta)

      queue2.tas.create!(@full_ta_hash.merge({ password: queue2.password }) )

      post :create, { :ta => ta_hash.merge({ :password => @queue.password }) }.merge(@queue_hash)

      response.code.should == "201"
    end


    it "successfully reads a ta" do
      authenticate QueueUser.where(:_id => @full_ta_hash[:id]).first
      get :show, { :id => @full_ta_hash[:id] }

      response.code.should == "200"

      res_hash = ActiveSupport::JSON.decode(response.body)

      res_hash.count.should == 3
    end

    it "successfully updates username" do
      authenticate QueueUser.where(:_id => @full_ta_hash[:id]).first
      new_username = "Harry"

      put :update, { :ta => { :username => new_username }, :id => @full_ta_hash[:id] }

      response.code.should == "204"
    end

    it "successfully destroys the TA if only one is logged in" do
      @queue.tas.destroy_all
      @queue.tas.create!(@full_ta_hash.merge(password: @queue.password))
      authenticate QueueUser.where(:_id => @full_ta_hash[:id]).first
      delete :destroy, { :id => @full_ta_hash[:id] }

      response.code.should == "204"

      QueueUser.where(:_id => @full_ta_hash[:id]).first.should be_nil
    end

    it "only decrements the login_count of the TA if more than one logged in" do
      @queue.tas.destroy_all
      ta = @queue.tas.create!(@full_ta_hash.merge(password: @queue.password))
      ta.login_count = 2
      ta.save!
      authenticate ta

      delete :destroy, { :id => @full_ta_hash[:id] }

      response.code.should == "204"

      QueueUser.where(:_id => @full_ta_hash[:id]).first.should_not be_nil
      ta = Ta.find(ta.id)
      ta.login_count.should == 1
    end
  end

  describe "Authentication" do
    before :each do
      @ta = @queue.tas.create!(attributes_for(:ta))
    end

    after :each do
      @ta.destroy
    end
    it "fails updating w/o credentials" do
      put :update, { :student => { :in_queue => true}, :id => @ta.id }
      response.code.should ==  "401"
    end

    it "fails destroying without authorization" do
      delete :destroy, { :id => @ta.id }

      response.code.should == "401"
    end

    it "fails reading a ta w/o credentials" do
      get :show, { :id => @ta.id }

      response.code.should == "401"
    end

  end
end

