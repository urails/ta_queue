class TasController < ApplicationController
  before_filter :get_board
  before_filter :get_ta, :only => [:update, :show, :destroy]
  before_filter :authenticate_ta!, :except => [:create]

  #after_filter :push_notify!, [:destroy, :create, :update]

  respond_to :json, :xml

  def show
    #respond_with @ta
  end

  def create 
    @ta = @board.tas.new(params[:ta].merge( :password => params[:queue_password]))
    respond_with do |f|
      if @ta.save
        sign_in @ta
        push_notify!
        f.html { redirect_to board_path @board }
        f.json { render :json => { token: @ta.token, id: @ta.id, username: @ta.username }, :status => :created }
        f.xml  { render :xml => { token: @ta.token, id: @ta.id, username: @ta.username }, :status => :created }
      else
        f.html { flash[:errors] = @ta.errors.full_messages; redirect_to board_login_path(@board, :ta => true) }
        f.json { render :json => @ta.errors, :status => :unprocessable_entity }
        f.json { render :xml => @ta.errors, :status => :unprocessable_entity }
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
    sign_out @ta
    push_notify!
    respond_with do |f|
      f.html { redirect_to board_login_path @board }
    end
  end

  private

    def get_ta
      @ta = @board.tas.find(params[:id])
      if !@ta
        render template: "shared/does_not_exist.rabl", :status => 422
      end
    end

    def get_board
      @board = Board.where(:title => params[:board_id])
    end
end
