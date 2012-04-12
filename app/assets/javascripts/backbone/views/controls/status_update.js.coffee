TaQueue.Views.Controls ||= {}

class TaQueue.Views.Controls.StatusUpdateShowView extends Backbone.View
  template: JST["backbone/templates/controls/status_update_show"]

  initialize: (options) ->
    @el = $("#queue_status")

  events:
    "click span.checking" : "swapEdit"

  swapEdit: ->
    console.log "got here"
    editView = new TaQueue.Views.Controls.StatusUpdateEditView
    editView.render()

  render: ->
    $(@el).html(@template(queue:window.queue))
    this

class TaQueue.Views.Controls.StatusUpdateEditView extends Backbone.View
  template: JST["backbone/templates/controls/status_update_edit"]

  initialize: (options) ->
    @el = $("#queue_status")

  render: ->
    $(@el).html(@template(queue:window.queue))
    this

