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

  ta_putback: ->
    @action "ta_putback"

class TaQueue.Collections.StudentsCollection extends Backbone.Collection
  model: TaQueue.Models.Student

  in_queue: ->
    @where in_queue: true

  in_queue_not_being_helped: ->
    @where in_queue: true, ta_id: null

  # This returns the first Student which is NOT the current_user
  firstStudent: () ->
    cu = window.queue.currentUser()
    for student in @models
      return student if student.get('id') != cu.get('id')
    return null

  url: '/students'
