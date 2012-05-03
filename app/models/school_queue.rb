require "helpers"
class SchoolQueue
  include Mongoid::Document

  # ATTRIBUTES

  field :title, type: String
  field :active, type: Boolean, default: true
  field :frozen, type: Boolean, default: false
  field :is_question_based, type: Boolean, default: false
  field :class_number, type: String
  field :status, type: String, default: ""
  field :password, type: String

  # ASSOCIATIONS

  belongs_to :instructor
  has_many :queue_users, dependent: :destroy
  # These associations work out of the box because of inheritance! Whoop whoop!
  has_many :tas
  has_many :students

  # VALIDATIONS

  validates :frozen, :active, :is_question_based, :inclusion => { :in => [true, false], :message => "must be a true/false value" }

  # SCOPES

  # CALLBACKS

  def to_param
    class_number
  end

end
