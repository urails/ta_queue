class TaQueue.Models.Queue extends Backbone.Model
  url: "/queue"

  initialize: (options) ->
    @students = new TaQueue.Collections.StudentsCollection
    @tas = new TaQueue.Collections.TasCollection

  parse: (response) ->
    @tas.reset(response.tas)
    delete response.tas
    @students.reset(response.students)
    delete response.students
    return response

  defaults:
    frozen: null
    active: null
    students: null
    tas: null


#class TaQueue.Collections.QueuesCollection extends Backbone.Collection
  #model: TaQueue.Models.Queue
  #url: '/queues'
