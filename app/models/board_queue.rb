class BoardQueue
  include Mongoid::Document

  belongs_to :board

  field :frozen, type: Boolean, default: false

  validates :frozen, :inclusion => { :in => [true, false], :message => "frozen must be a true/false value" }
  # Not currently a proper association for students in the queue or not,
  # students have a boolean that determines that

  def state
    hash = {}
    hash[:frozen] = self.frozen 
    hash[:active] = self.board.active
    hash[:students] = self.students.as_json
    hash[:tas] = self.tas.as_json
    hash
  end

  def active
    self.board.active
  end

  def as_json options = {}
    state
  end

  def students
    self.board.students.in_queue
  end

  def tas
    self.board.tas
  end

end
