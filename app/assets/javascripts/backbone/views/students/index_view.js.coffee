TaQueue.Views.Students ||= {}

class TaQueue.Views.Students.IndexView extends TaQueue.View
  template: JST["backbone/templates/students/index"]

  # This refers to the id given to the DOM element (which is by default a div)
  id: "queue_list"

  initialize: (options) ->
    super(options)
    @students = options.students
    @bind()
    _.bindAll(this, 'updateClock', 'render', 'updateStudentViews')
    @updateClock()
    window.setInterval @updateClock, 3000
    this

  bind: =>
    window.queue.on 'change', @render, this

  render: =>
    return null unless @active
    $(@el).html(@template())
    @updateClock()
    @updateStudentViews()
    return this

  updateStudentViews: ->
    el = $(@el).find("#student_queue_list")
    #$(el).after("")
    _.forEach @students.in_queue(), (student) ->
      view = new TaQueue.Views.Students.ShowView(student: student)
      $(el).append view.render().el
      #el = view.el

  updateClock: ->
    #$(@el).find("#queue_datetime span.left").html(window.util.getDate())
    #$(@el).find("#queue_datetime span.right").html(window.util.getTime())
    
