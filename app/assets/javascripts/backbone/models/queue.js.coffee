class TaQueue.Models.Queue extends TaQueue.Model
  url: "/queue"

  initialize: (options) ->
    @students = new TaQueue.Collections.StudentsCollection
    @tas = new TaQueue.Collections.TasCollection
    @bind 'change', @refresh, this

  refresh: ->
    @students.reset @get('students')
    @tas.reset @get('tas')

  defaults:
    frozen: null
    active: null
    students: null
    tas: null

  isNew: -> false


#class TaQueue.Collections.QueuesCollection extends Backbone.Collection
  #model: TaQueue.Models.Queue
  #url: '/queues'
