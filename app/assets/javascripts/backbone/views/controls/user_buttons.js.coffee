TaQueue.Views.Controls ||= {}

class TaQueue.Views.Controls.UserButtons extends TaQueue.View
  template: JST["backbone/templates/controls/user_buttons"]

  initialize: (options) ->
    @bind()
    super options
    _.bindAll(this, 'render', 'toggleActive', 'toggleFrozen')

  bind: ->
    window.queue.bind "change", @render, this

  id: 'control_bar'

  disabled_enter_queue: -> $("#enter_queue.disabled")

  events:
    "click #activate_queue" : "toggleActive"
    "click #freeze_queue" : "toggleFrozen"
    "click #sign_out" : "signOut"
    "click #enter_queue" : "toggleEnterQueue"

  render: ->
    return null unless @active
    $(@el).html(@template(current_user:window.queue.currentUser(), queue:window.queue))
    @delegateEvents()
    @simpleTip()

  simpleTip: ->
    #$("#ta_auto_accept").simpletip
      #content: "Checking this box causes the next student to be auto-accepted when the student you are helping removes themselves from the queue",
      #fixed: true,
      #position:"top",
      #offset: [0, -10]

    return null if @disabled_enter_queue().length == 0

    content = "A TA has frozen the queue, no more students may enter at this time." if window.queue.get('frozen')
    content = "A TA has not activated the queue." if !window.queue.get('active')
    el = @disabled_enter_queue()
    el.simpletip
      content: content,
      fixed: true,
      position: "top",
      offset: [0, -10]


  toggleActive: ->
    queue = window.queue
    queue.toggle('active')
    queue.save()

  toggleFrozen: ->
    queue = window.queue
    queue.toggle('frozen')
    queue.save()

  toggleEnterQueue: ->
    return null if !window.queue.get('active') || window.queue.get('frozen')

    text = null
    if window.queue.get('is_question_based') && !queue.currentUser().get('in_queue')
      text = prompt "What's your question?"
      return if text == null || text == ''

    if window.queue.currentUser().get('in_queue')
      queue.exit_queue()
    else
      queue.enter_queue(text)

  signOut: ->
    window.jug_handler.unsubscribe()
    window.queue.currentUser().destroy
      wait: true
      success: ->
        window.location = window.login_url
