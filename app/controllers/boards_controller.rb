class BoardsController < ApplicationController
  respond_to :xml, :json, :html
  before_filter :get_board, :except => [:new, :create, :index]
  before_filter :authenticate_ta!, :only => [:update]
  before_filter :authenticate_user_for_current_board!, :only => [:show]
  before_filter :filter_users, :only => [:login]
  before_filter :authenticate_master_password!, :only => [:create, :destroy]

  @@master_password = "create_queue"

  def create
      @board = Board.new(params[:board])
      @board.save
      respond_with @board
  end

  def update
    @board.update_attributes(params[:board])
    respond_with @board
  end

  def new
    @board = Board.new
  end

  def index
    @boards = Board.all
    respond_with @boards
  end

  def show
    respond_with @board
  end

  def new_show
  end

  def login
    @ta = Ta.new
    @student = Student.new    
  end

  def destroy
    @board.destroy
    respond_with @board
  end

  private

    def get_board
      if params[:id]
        @board = Board.where(:title => params[:id]).first
      else
        @board = Board.where(:title => params[:board_id]).first
      end

      if @board.nil?
        redirect_to root_path and return
      end
    end

    def filter_users
      if current_user
        redirect_to @board
      end
    end

    def authenticate_user_for_current_board!
      authorize!
      unless current_user && @board.queue_users.where(:_id => current_user.id).first
        respond_with do |f|

          # This needs to be checked so that it doesn't get stuck in an infinite redirect
          if current_user
            f.html { redirect_to boards_path, :notice => "You are already logged into #{current_user.board.title}, please log out before entering another Board." }
          else
            f.html { redirect_to board_login_path @board }
          end

          f.json { render :json => { :error => "You are not authorized to access this board" }, :status => :unauthorized }
          f.xml  { render :json => { :error => "You are not authorized to access this board" }, :status => :unauthorized }
        end
      end
    end

    def authenticate_master_password!
      unless params[:master_password] == @@master_password
        respond_with do |f|
          f.json { render :json => { :error => "Destorying a Board requires a valid master password." }, :status => :unauthorized }
        end
      end
    end


end
