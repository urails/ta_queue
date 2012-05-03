require "helpers"
class SchoolQueue
  include Mongoid::Document

  # ATTRIBUTES

  field :frozen, type: Boolean, default: false
  field :title, type: String
  field :class_number, type: String
  field :active, type: Boolean, default: true
  field :status, type: String, default: ""
  field :password, type: String

  # ASSOCIATIONS

  belongs_to :instructor
  has_many :queue_users, dependent: :destroy
  # These associations work out of the box because of inheritance! Whoop whoop!
  has_many :tas
  has_many :students

  # VALIDATIONS

  validates :frozen, :active, :inclusion => { :in => [true, false], :message => "must be a true/false value" }

  # SCOPES

  # CALLBACKS

end
