TaQueue.Views.Students ||= {}

class TaQueue.Views.Students.IndexView extends Backbone.View
  template: JST["backbone/templates/students/index"]

  # This refers to the id given to the DOM element (which is by default a div)
  id: "queue_list"

  initialize: (options) ->
    @students = options.students
    @students.bind 'reset', @render, this
    _.bindAll(this, 'updateClock', 'render', 'updateStudentViews')
    @updateClock()
    window.setInterval @updateClock, 3000
    this

  render: ->
    $(@el).html(@template())
    @updateClock()
    @updateStudentViews()
    return this

  updateStudentViews: ->
    el = $(@el).find("#queue_datetime")
    $(el).after("")
    _.forEach @students.in_queue(), (student) ->
      view = new TaQueue.Views.Students.ShowView(student: student)
      $(el).after view.render().el
      el = view.el

  updateClock: ->
    $(@el).find("#queue_datetime span.left").html(window.util.getDate())
    $(@el).find("#queue_datetime span.right").html(window.util.getTime())
    
