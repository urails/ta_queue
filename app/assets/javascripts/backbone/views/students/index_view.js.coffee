TaQueue.Views.Students ||= {}

class TaQueue.Views.Students.IndexView extends Backbone.View
  template: JST["backbone/templates/students/index"]

  render: ->
    $(@el).html(@template())
    return this
