class Instructors::QueuesController < InstructorsController
  before_filter :authenticate_instructor!
  before_filter :get_queue, only: [:edit, :update, :destroy, :show]

  def show
  end
  
  def index
  end

  def new
    @queue = SchoolQueue.new
  end

  def create
    @queue = SchoolQueue.new(params[:school_queue])
    @queue.instructor = current_instructor
    
    if @queue.save
      flash[:notice] = "Queue Successfully Created!"
      redirect_to edit_instructors_queue_path(@queue)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @queue.update_attributes(params[:school_queue])
    if @queue.save
      flash[:notice] = "Updated!"
      redirect_to edit_instructors_queue_path @queue
    else
      render :edit
    end
  end

  def destroy
    @queue.destroy
    flash[:notice] = "Queue deleted!"
    redirect_to instructors_dashboard_path
  end

  private

    def get_queue
      @queue = current_instructor.queues.where(class_number: params[:id]).first
      redirect_to instructors_dashboard_path unless @queue
    end

end
