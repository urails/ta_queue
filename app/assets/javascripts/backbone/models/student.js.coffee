class TaQueue.Models.Student extends TaQueue.Model
  paramRoot: 'student'

  initialize: (options) ->
    console.log "got to student"

  defaults:
    token: null
    username: null
    location: null
    in_queue: null
    question: null

class TaQueue.Collections.StudentsCollection extends Backbone.Collection
  model: TaQueue.Models.Student

  in_queue: ->
    @where in_queue: true

  url: '/students'
