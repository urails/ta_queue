TaQueue.Views.Controls ||= {}

class TaQueue.Views.Controls.UserButtons extends Backbone.View
  template: JST["backbone/templates/controls/user_buttons"]

  initialize: (options) ->
    _.bindAll(this, 'render', 'toggleActive', 'toggleFrozen')

  id: 'control_bar'

  events:
    "click #activate_queue" : "toggleActive"
    "click #freeze_queue" : "toggleFrozen"
    "click #sign_out" : "signOut"
    "click #enter_queue" : "toggleEnterQueue"
    "click #routeroute" : "route"

  route: ->
    window.queueRouter.navigate("", { trigger: true })

  render: ->
    $(@el).html(@template(current_user:@options.current_user, queue:@options.queue))
    this

  toggleActive: ->
    queue = window.queue
    queue.toggle('active')
    queue.save()

  toggleFrozen: ->
    queue = window.queue
    queue.toggle('frozen')
    queue.save()

  toggleEnterQueue: ->
    if window.current_user.get('in_queue')
      queue.exit_queue()
    else
      queue.enter_queue()

  signOut: ->
    window.current_user.destroy(
      wait: true
      success: (model, response) ->
        window.location = "/"
    )
