class School
  include Mongoid::Document

  # ATTRIBUTES

  field :name, type: String
  field :contact_email, type: String
  field :abbreviation, type: String
  field :master_password, type: String

  # ASSOCIATIONS
  
  has_many :instructors, dependent: :destroy

  # VALIDATIONS
  
  # CALLBACKS
  

  def to_param
    abbreviation
  end
  
end
