class Instructor::QueuesController < InstructorController
  def show
    @queue = SchoolQueue.where(class_number: params[:id]).first
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
      redirect_to instructor_queue_path(@queue)
    else
      flash[:notice] = "It didn't work."
      render :new
    end

  end

  def edit
    @queue = SchoolQueue.where(class_number: params[:id]).first
  end

  def update
    @queue = SchoolQueue.where(class_number: params[:id]).first
    @queue.update_attributes(params[:school_queue])
    flash[:notice] = "Updated!"
    redirect_to instructor_queue_path @queue
  end

  def destroy
    @queue.destroy
    flash[:notice] = "Queue deleted!"
    redirect_to instructor_root_path
  end

end
