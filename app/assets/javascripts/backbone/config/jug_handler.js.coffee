class JugHandler
  queue_path: -> "queue/#{window.queue_id}"
  chat_path: -> "chats/#{window.user_token}"

  start_juggernaut: () ->
    jug = new Juggernaut()
    @jug_object = jug

    jug.subscribe @queue_path() , (data) ->
      console.log $.parseJSON(data)
      window.queue.set($.parseJSON(data))

    jug.subscribe @chat_path(), (data) ->
      window.chatsRouter.receivedMessage data.from, data.message

  unsubscribe: ->
    @jug_object.unsubscribe @queue_path()
    @jug_object.unsubscribe @chat_path()
    
    

$(document).ready () ->
  if window.jug_handler == undefined
    window.jug_handler = new JugHandler()
    window.jug_handler.start_juggernaut()
