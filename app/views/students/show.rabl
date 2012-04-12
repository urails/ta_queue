object @student

attribute :_id => :id
node(:username) { |stud| escp(stud.username) }
attribute :location
child :ta => :ta do
  extends "tas/show"
end
node(:in_queue){ |stud| !!stud.in_queue }
