class Notification
  include Mongoid::Document
  has_and_belongs_to_many :queue_users

  field :content, type: String
end
