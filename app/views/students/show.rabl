object @student

attribute :_id => :id
node(:username) { |stud| escp(stud.username) }
attribute :location

node(:in_queue) { |stud| !!stud.in_queue }

node(:ta_id) { |stud| stud.ta ? stud.ta.id.to_s : nil }
