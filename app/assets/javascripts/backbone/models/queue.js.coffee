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

  action: (action_name, text) ->
    $.get("#{@url}/#{action_name}", question: text)

  enter_queue: (text) ->
    @action "enter_queue", text

  currentUser: ->
    if window.user_type == "Ta"
      return @tas.get(window.user_id)
    else
      return @students.get(window.user_id)

  exit_queue: ->
    @action "exit_queue"

  isNew: -> false


#class TaQueue.Collections.QueuesCollection extends Backbone.Collection
  #model: TaQueue.Models.Queue
  #url: '/queues'
