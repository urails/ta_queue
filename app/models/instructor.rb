class Instructor
  include Mongoid::Document

  # ATTRIBUTES

  field :name, type: String
  field :username, type: String

  # ASSOCIATIONS

  embedded_in :school
  embeds_many :school_queues, cascade_callbacks: true

  # SCOPES
  
  # CALLBACKS

  def queues
    self.school_queues
  end

end
