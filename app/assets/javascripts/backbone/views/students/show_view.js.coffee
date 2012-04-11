TaQueue.Views.Students ||= {}

class TaQueue.Views.Students.ShowView extends Backbone.View
  template: JST["backbone/templates/students/show"]

  className: 'even student'

  render: ->
    $(@el).html(@template(student: @options.student.attributes))
    return this
