object @ta

attributes :id, :status
node(:username) { |ta| escp(ta.username) }

child :student do
  extends "students/show"
end
