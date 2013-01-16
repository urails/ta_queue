require "helpers"
class Ta < QueueUser

  # ATTRIBUTES
  
  attr_accessor :password
  field :login_count, type: Integer, default: 1

  # ASSOCIATIONS
  
  has_one :student, :class_name => "Student", dependent: :nullify
  # NOTE: there does NOT need to be a belongs_to :school_queue because that
  # is declared in QueueUser

  # VALIDATIONS

  validate :check_password!, :on => :create
  validates :username, uniqueness: { scope: :school_queue_id }

  # SCOPES
  
  # CALLBACKS

  def accept_student stud
    if self.student
      prev_student = self.student
      prev_student.exit_queue!
      self.save
    end
    stud.enter_queue!
    self.student = stud
  end

  def accept_student! stud
    accept_student stud
    save
  end

  # If there are students left in the queue, accept the next one
  def accept_next_student
    if stud = queue.students.in_queue.first
      accept_student! stud
    end
  end

  def check_password!
    if self.password != self.queue.password
      self.errors["password"] = "is invalid"
      return false
    else
      return true
    end
  end

end
