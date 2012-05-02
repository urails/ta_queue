class JugHandler
  start_juggernaut: () ->
    jug = new Juggernaut()

    queue_path = "#{window.board_title}/queue"
    console.log "Connecting to #{queue_path}..."
    jug.subscribe queue_path , (data) ->
      window.queue.set($.parseJSON(data))

    chat_path = "chats/#{window.user_token}"
    console.log "Connecting to #{chat_path}..."
    jug.subscribe chat_path, (data) ->
      console.log data
      window.chatsRouter.receivedMessage data.from, data.message
    

$(document).ready () ->
  if window.jug_handler == undefined
    window.jug_handler = new JugHandler()
    window.jug_handler.start_juggernaut()
