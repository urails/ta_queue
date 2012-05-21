TaQueue.Views.Controls ||= {}

class TaQueue.Views.Controls.StatusUpdateShowView extends Backbone.View
  template_show: JST["backbone/templates/controls/status_update_show"]
  template_edit: JST["backbone/templates/controls/status_update_edit"]

  initialize: (options) ->
    @queue = options.queue
    @bind()
    @current_template = @template_show

  bind: =>
    @queue.on "change", @render, this

  events:
    "click .checking" : "swapEdit"
    "keypress #queue-status-update" : "checkEnter"

  swapEdit: ->
    return if window.queue.currentUser().isStudent

    $(@el).find("div").remove()
    @current_template = @template_edit
    @render()

    $(@el).find("#queue-status-update").get(0).select()

  checkEnter: (e) ->
    return if (e.keyCode != 13)
    $(@el).undelegate("#queue-status-update", "keypress")
    @current_template = @template_show
    queue.save('status' : $(@el).find("#queue-status-update").val())

  render: ->
    $(@el).html(@current_template(queue:@queue))
    @delegateEvents()
    this
