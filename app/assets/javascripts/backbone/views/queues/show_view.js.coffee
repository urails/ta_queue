TaQueue.Views.Queues ||= {}

class TaQueue.Views.Queues.ShowView extends Backbone.View
  template: JST["backbone/templates/queues/show"]

  render: ->
    $(@el).html(@template())
    return this
