TaQueue.Views.Chat ||= {}

class TaQueue.Views.Chat.MessagesView extends TaQueue.View
  initialize: (options) ->
    super options
    @selected = options.selected

  render: (id) ->
    return null unless @active
    @selected = id
    $(@el).html(@userDiv(@selected))
    @scroll id, 0

  appendClientMessage: (id, message) ->
    @render id
    @userDiv(id).append("<p class=\"sent\">#{window.queue.currentUser().get('username')}: #{message}</p>")
    @scroll id, 200

  appendReceivedMessage: (id, message) ->
    if user = window.queue.tas.get(id)
      username = user.get('username')
    else if user = window.queue.students.get(id)
      username = user.get('username')

    @userDiv(id).append("<p class=\"received\">#{username}: #{message}</p>")
    if id == @selected
      @scroll id, 200

  scroll: (id, duration) ->
    $(@el).animate({ scrollTop: $(@userDiv(id)).height() }, duration)
    
  # Returns a div with the chat conversation for user with id
  userDiv: (id) ->
    # Check's the cache to see a div has already been made
    if data = $.data(@el, id)
      return data
    
    # Create a new div
    el = $("<div class=\"message_box\"></div>")

    # Save it in the cache
    $.data(@el, id, el)

    return el
    
