object @board

attribute :active
node(:title) { |board| escp(board.title) }

child :tas do
  extends "tas/show" 
end

child :students do
  extends "students/show"
end

# It comes back as board_queue by default, so force it to use queue
child :queue => :queue do
  extends "queues/show"
end
