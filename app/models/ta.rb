require "helpers"
class Ta < QueueUser

  # ATTRIBUTES
  
  field :status, type: String, default: ""
  attr_accessor :password

  # ASSOCIATIONS
  
  has_one :student, :class_name => "Student", dependent: :nullify
  # NOTE: there does NOT need to be a belongs_to :school_queue because that
  # is declared in QueueUser

  # VALIDATIONS

  validate :check_password, :on => :create
  validates :username, :uniqueness => true

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
    if stud = board.students.in_queue.first
      accept_student! stud
    end
  end

  private

    def check_password
      if self.password != self.queue.password
        self.errors["password"] = "is invalid"
      end
    end
end
