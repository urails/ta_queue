require "helpers"
class Ta < QueueUser
  has_one :student, :class_name => "Student", dependent: :nullify

  field :status, type: String, default: ""
  attr_accessor :password

  validate :check_password, :on => :create
  validates :username, :uniqueness => true

  #def output_hash
    #hash = {}
    #hash[:id] = id.to_s
    #hash[:username] = escp(username)
    #hash[:student] = self.student
    #hash[:status] = self.status
    #hash
  #end

  def self.create_mock options = {}
    Ta.create!(:username => "Stanley", :token => SecureRandom.uuid)
  end

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
      if self.password != self.board.password
        self.errors["password"] = "is invalid"
      end
    end
end
