class TaQueue.Models.Student extends TaQueue.Model
  paramRoot: 'student'

  initialize: (options) ->
    @action "foobar"

  defaults:
    token: null
    username: null
    location: null
    in_queue: null
    question: null

class TaQueue.Collections.StudentsCollection extends Backbone.Collection
  model: TaQueue.Models.Student
  url: '/students'
