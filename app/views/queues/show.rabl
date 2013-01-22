object @queue

attribute :frozen, :is_question_based
node(:active) { |q| q.active }
node(:status) { |q| escp(q.status) }
node(:id) { |q| q.id.to_s }

child :students => :students do |stud|
  extends "students/show"  
end

child :tas => :tas do
  extends "tas/show"
end
