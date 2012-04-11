TaQueue.Views.Controls ||= {}

class TaQueue.Views.Controls.UserButtons extends Backbone.View
  template: JST["backbone/templates/controls/user_buttons"]

  initialize: (options) ->
    _.bindAll(this, 'render', 'toggleActive')

  id: 'control_bar'

  events:
    "click #activate_queue" : "toggleActive"

  render: ->
    $(@el).html(@template(current_user:@options.current_user, queue:@options.queue))
    @delegateEvents()
    console.log $(@el).find("#activate_queue")
    this

  toggleActive: ->
    console.log 'toggleActive called'
    queue = window.queue
    queue.toggle('active')
    queue.save()
