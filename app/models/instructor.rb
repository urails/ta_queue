class Instructor
  include Mongoid::Document

  # ATTRIBUTES

  field :name, type: String
  field :username, type: String

  # ASSOCIATIONS

  belongs_to :school
  has_many :school_queues, dependent: :destroy

  # SCOPES
  
  # CALLBACKS

  def queues
    self.school_queues
  end

  def to_param
    username
  end

end
