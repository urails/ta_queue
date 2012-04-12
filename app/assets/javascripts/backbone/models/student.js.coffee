class TaQueue.Models.Student extends TaQueue.Model
  paramRoot: 'student'

  isTa: false
  isStudent: true

  defaults:
    token: null
    username: null
    location: null
    in_queue: null
    question: null

  ta_accept: ->
    @action "ta_accept"

  ta_remove: ->
    @action "ta_remove"

class TaQueue.Collections.StudentsCollection extends Backbone.Collection
  model: TaQueue.Models.Student

  in_queue: ->
    @where in_queue: true

  url: '/students'
