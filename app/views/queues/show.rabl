object @queue

attribute :frozen
node(:active) { |q| q.board.active }
node(:status) { |q| escp(q.status) }
child :students do
  extends "students/show"
end

child :tas do
  extends "tas/show"
end
