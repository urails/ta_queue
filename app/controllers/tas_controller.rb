class TasController < ApplicationController
  before_filter :authenticate_ta!, :except => [:create]
  before_filter :get_queue
  before_filter :get_ta, :only => [:update, :show, :destroy]

  #after_filter :push_notify!, [:destroy, :create, :update]

  respond_to :json, :xml

  def show
    respond_with @ta
  end

  def create 
    @ta = @queue.tas.where(username: params[:ta][:username]).first
    if !@ta
      @ta = @queue.tas.new
    end
    @ta.update_attributes(params[:ta])
    respond_with do |f|
      if @ta.check_password! && @ta.save
        sign_in_user @ta
        @current_user = @ta
        push_notify!
        f.html { redirect_to queue_path }
        f.json { render :json => { token: @ta.token, id: @ta.id, username: @ta.username }, :status => :created }
        f.xml  { render :xml => { token: @ta.token, id: @ta.id, username: @ta.username }, :status => :created }
      else
        f.html { flash[:errors] = @ta.errors.full_messages; redirect_to build_queue_login_path(@queue, :ta => true) }
        f.json { render :json => { errors: @ta.errors.full_messages }, :status => :unprocessable_entity }
        f.xml  { render :xml =>  { errors: @ta.errors.full_messages }, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @ta.update_attributes(params[:ta])
    @ta.save

    push_notify!
    respond_with @ta
  end

  def destroy
    @ta.destroy

    sign_out_user @ta
    push_notify!

    respond_with do |f|
      f.html { redirect_to build_queue_login_path @ta.queue }
    end
  end

  private

    def get_ta
      @ta = @queue.tas.find(params[:id])
      if !@ta
        render template: "shared/does_not_exist", :status => 422
      end
    end
end
