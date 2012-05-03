class School
  include Mongoid::Document

  # ATTRIBUTES

  field :name, type: String
  field :contact_email, type: String
  field :abbreviation, type: String
  field :master_password, type: String

  # ASSOCIATIONS
  
  embeds_many :instructors, cascade_callbacks: true

  # VALIDATIONS
  
  # CALLBACKS
  
end
