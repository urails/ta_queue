collection @schools

attribute :name, :abbreviation

child :instructors => :instructors do
  attribute :name, :username
  child :queues => :queues do
    attribute :active, :frozen, :class_number, :title, :id
  end
end
