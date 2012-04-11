TaQueue.Views.Controls ||= {}

class TaQueue.Views.Controls.UserButtons extends Backbone.View
  template: JST["backbone/templates/controls/user_buttons"]

  initialize: (options) ->
    _.bindAll(this, 'render', 'toggleActive', 'toggleFrozen')

  id: 'control_bar'

  events:
    "click #activate_queue" : "toggleActive"
    "click #freeze_queue" : "toggleFrozen"

  render: ->
    $(@el).html(@template(current_user:@options.current_user, queue:@options.queue))
    @delegateEvents()
    this

  toggleActive: ->
    queue = window.queue
    queue.toggle('active')
    queue.save()

  toggleFrozen: ->
    queue = window.queue
    queue.toggle('frozen')
    queue.save()
