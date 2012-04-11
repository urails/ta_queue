require "helpers"
class BoardQueue
  include Mongoid::Document

  belongs_to :board

  field :frozen, type: Boolean, default: false
  field :active, type: Boolean, default: true
  field :status, type: String, default: ""

  validates :frozen, :active, :inclusion => { :in => [true, false], :message => "frozen must be a true/false value" }
  # Not currently a proper association for students in the queue or not,
  # students have a boolean that determines that

  def students
    self.board.students
  end

  def tas
    self.board.tas
  end

end
