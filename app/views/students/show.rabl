object @student

attribute :_id => :id 
node(:username) { |stud| escp(stud.username) }
node(:location) { |stud| escp(stud.location) }
attribute :question if current_user.ta? || current_user == @student

node(:in_queue) { |stud| !!stud.in_queue }

node(:ta_id) { |stud| stud.ta ? stud.ta.id.to_s : nil }
