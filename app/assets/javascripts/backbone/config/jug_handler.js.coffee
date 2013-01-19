class FayeHandler
  queue_path: -> "/queue/#{window.queue_id}"
  chat_path: -> "/chats/#{window.user_token}"

  start_faye: () ->
    @faye = new Faye.Client('http://localhost:9292/faye');

    @faye.subscribe @queue_path() , (data) ->
      window.queue.set($.parseJSON(data))

    @faye.subscribe @chat_path(), (data) ->
      window.chatsRouter.receivedMessage data.from, data.message

  unsubscribe: ->
    @faye.unsubscribe @queue_path()
    @faye.unsubscribe @chat_path()
    
    

$(document).ready () ->
  if window.faye_handler == undefined
    window.faye_handler = new FayeHandler()
    window.faye_handler.start_faye()
