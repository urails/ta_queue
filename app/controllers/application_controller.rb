class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  @@user_id_cookie_name = "_queue"

  private

    def render_queue
      source = File.read('app/views/queues/show.rabl')
      rabl_engine = Rabl::Engine.new(source, :format => 'json')
      output = rabl_engine.render(self, {})
    end

    def push_notify!
      if Rails.env != "test"
        @queue = current_user.board.queue
        Juggernaut.publish("#{current_user.board.title}/queue", render_queue) #current_user.board.queue.as_json)
      end
    end

    def current_user
      authorize!
      @current_user
    end

    # Simply grabs the user using the HTTP Credentials, does NOT redirect due to multiple redirects
    # being called if it happens here
    def authorize!
      if request.format != "html"
        @current_user ||= authenticate_with_http_basic do |u, p| logger.debug "CREDENTIALS: " + u.to_s + " " + p.to_s; QueueUser.where(:_id => u, :token => p).first end

      else
        @current_user ||= QueueUser.where(:_id => cookies.signed[@@user_id_cookie_name]).first
      end

      if @current_user
        keep_alive @current_user
      end
    end

    def authenticate!
      authorize!
      if current_user.nil?
        respond_with do |f|
          f.json { render :json => { :error => "You are not authorized to perform this action" }, :status => :unauthorized }
        end
      end
    end


    def get_board
      #if current_user
        @board ||= current_user.board
      #else
        #if params[:controller] == "boards"
          #@board ||= Board.where(:title => params[:id]).first
        #else
          #@board ||= Board.where(:title => params[:board_id]).first
        #end
      #end
    end

    # if the board is inactive, redirect
    def check_active
      unless @queue.active
        respond_with do |f|
          f.json { render :json => { :error => "You cannot enter the queue when it is frozen" }, :status => :forbidden }
        end
      end
    end

    def authenticate_student! options = {}
      authorize!
      if options[:current] == true
        unless current_user and current_user.student? and QueueUser.where(:_id => params[:id]).first == current_user
          send_head_with :unauthorized and return
        end
      else
        unless current_user and current_user.student?
          send_head_with :unauthorized and return
        end
      end
    end

    def authenticate_current_student!
      authenticate_student! current: true
    end

    def authenticate_current_student_or_ta!
      authorize!
      unless current_user && current_user.ta?
        authenticate_current_student!
      end
    end

    def authenticate_ta! options = {}
      authorize!
      if options[:current] == true
        unless current_user and current_user.ta? and QueueUser.where(:_id => params[:id]).first == current_user
          send_head_with :unauthorized and return
        end
      else
        unless current_user and current_user.ta?
          send_head_with :unauthorized and return
        end
      end
    end

    # Helper for sending heads
    def send_head_with symbol=nil, message=nil, path=nil
      _message ||= "You are not authorized to access this page"
      _symbol ||= :unauthorized
      _path ||= root_path

      respond_with do |f|
        f.html { redirect_to _path, :notice => _message }
        f.json { head _symbol }
        f.xml  { head _symbol }
      end
    end

    # Makes sure that users that are making requests often are "kept alive" so the
    # crom task doesn't wipe them out.
    def keep_alive user
      if user.alive_time.nil?
        user.alive_time = DateTime.now
        user.save
        logger.debug "Alive time updated"
      else
        if user.alive_time + 15.minutes < DateTime.now
          user.alive_time = DateTime.now
          user.save
          logger.debug "Alive time updated"
        end
      end
    end

    def sign_in user
      if request.format == "html"
        cookies.permanent.signed[@@user_id_cookie_name] = user.id
      end
    end

    def signed_in_id
      if request.format == "html"
        cookies.signed.delete @@user_id_cookie_name
      end
    end

    def sign_out user
      if request.format == "html"
        cookies.permanent.signed[@@user_id_cookie_name] = nil
      end
    end

end
