TaQueue.Views.Controls ||= {}

class TaQueue.Views.Controls.UserButtons extends Backbone.View
  template: JST["backbone/templates/controls/user_buttons"]

  initialize: (options) ->
    window.queue.bind "change", @render, this
    _.bindAll(this, 'render', 'toggleActive', 'toggleFrozen')

  id: 'control_bar'

  events:
    "click #activate_queue" : "toggleActive"
    "click #freeze_queue" : "toggleFrozen"
    "click #sign_out" : "signOut"
    "click #enter_queue" : "toggleEnterQueue"

  render: ->
    console.log "render called"
    $(@el).html(@template(current_user:window.queue.currentUser(), queue:window.queue))
    @centerControlBar()
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

  toggleEnterQueue: ->
    if window.queue.currentUser().get('in_queue')
      queue.exit_queue()
    else
      queue.enter_queue()

  signOut: ->
    window.queue.currentUser().destroy()
      wait: true
      success: (model, response) ->
        window.location = "/"

  centerControlBar: ->
    parentWidth = $('#control_panel').innerWidth()
    childWidth = $('#control_bar').innerWidth()
    margin = (parentWidth - childWidth)/2

    $('#control_bar').css('margin-left', margin + 'px')
