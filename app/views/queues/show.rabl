object @queue

attribute :frozen
node(:active) { |q| q.active }
node(:status) { |q| escp(q.status) }

child :students => :students do
  extends "students/show"
end

child :tas => :tas do
  extends "tas/show"
end
