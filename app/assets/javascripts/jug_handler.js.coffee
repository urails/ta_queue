class JugHandler
  start_juggernaut: (queue) ->
    console.log("running")
    window.board_title = $('#board_title').val();
    jug = new Juggernaut
    jug.on "disconnect", ->
      alert "You seem to have lost your internet connection. Please refresh the page."
    jug.subscribe "#{window.board_title}/queue", (data) ->
      queue.queryQueueSuccess(data)
    

$( () ->
  window.jug_handler = new JugHandler
)
