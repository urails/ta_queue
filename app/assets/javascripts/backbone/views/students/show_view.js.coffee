TaQueue.Views.Students ||= {}

class TaQueue.Views.Students.ShowView extends Backbone.View
  template: JST["backbone/templates/students/show"]

  className: 'even student'

  events:
    "click .ta_control .accept" : "acceptStudent"
    "click .ta_control .remove" : "removeStudent"

  acceptStudent: ->
    @options.student.ta_accept()

  removeStudent: ->
    @options.student.ta_remove()

  render: ->
    $(@el).html(@template(student: @options.student.attributes))
    return this
