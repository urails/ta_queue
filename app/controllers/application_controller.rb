class ApplicationController < ActionController::Base
  #protect_from_forgery
  helper_method :current_user, :render_queue, :build_queue_login_path
  helper_method :build_create_student_path, :build_create_ta_path

  @@user_id_cookie_name = "_queue"

  def after_sign_in_path_for instructor
    instructors_dashboard_path
  end


  private
    def build_queue_login_path queue, options={}
      queue_login_path queue.instructor.school, queue.instructor, queue, options
    end

    def build_create_student_path queue, options={}
      create_student_path queue.instructor.school, queue.instructor, queue, options
    end

    def build_create_ta_path queue, options={}
      create_ta_path queue.instructor.school, queue.instructor, queue, options
    end

    def render_queue
      @queue = current_user.queue
      source = File.read('app/views/queues/show.rabl')
      rabl_engine = Rabl::Engine.new(source, :format => 'json')
      output = rabl_engine.render(self, {})
    end

    def push_notify!
      if Rails.env != "test"
        Juggernaut.publish("queue/#{current_user.queue.id.to_s}", render_queue)
      end
    end

    def current_user
      authorize!
      @current_user
    end

    # Simply grabs the user using the HTTP Credentials, does NOT redirect due to multiple redirects
    # being called if it happens here
    def authorize!
      return if @current_user # No need to continue if the current_user has already been found
      
      if request.format != "html"
        @current_user ||= authenticate_with_http_basic do |u, p| 
          logger.debug "CREDENTIALS: " + u.to_s + " " + p.to_s 
          QueueUser.where(:_id => u, :token => p).first 
        end

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
          f.json { render :json => { :errors => ["You are not authorized to perform this action"] }, :status => :unauthorized }
          f.html { redirect_to root_path }
        end
      end
    end

    # if the board is inactive, redirect
    def check_active
      unless @queue.active
        respond_with do |f|
          f.json { render :json => { :errors => ["You cannot enter the queue when it is deactivated"] }, :status => :forbidden }
        end
      end
    end

    def authenticate_student! options = {}
      authorize!
      if options[:current] == true
        unless current_user and current_user.student? and QueueUser.where(:_id => params[:id]).first == current_user
          render json: { errors: "You are not authorized to perform this action." }, status: :unauthorized and return
        end
      else
        unless current_user and current_user.student?
          render json: { errors: "You are not authorized to perform this action." }, status: :unauthorized and return
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
          render json: { errors: "You are not authorized to perform this action." }, status: :unauthorized and return
        end
      else
        unless current_user and current_user.ta?
          render json: { errors: "You are not authorized to perform this action." }, status: :unauthorized and return
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

    def sign_in_user user
      if request.format == "html"
        cookies.permanent.signed[@@user_id_cookie_name] = user.id
      end
    end

    def signed_in_id
      if request.format == "html"
        cookies.signed.delete @@user_id_cookie_name
      end
    end

    def sign_out_user user
      if request.format == "html"
        cookies.permanent.signed[@@user_id_cookie_name] = nil
      end
    end

    def get_queue
      if current_user
        @queue = current_user.queue
      else
        @queue = School.where( abbreviation: params[:school] ).first \
                       .instructors.where( username: params[:instructor] ).first \
                       .queues.where( class_number: params[:queue] ).first
      end
    end

end
