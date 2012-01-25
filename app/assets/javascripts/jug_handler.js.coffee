class JugHandler
  start_juggernaut: (queue) ->
    window.board_title = $('#board_title').val();
    jug = new Juggernaut
    jug.subscribe "#{window.board_title}/queue", (data) ->
      queue.queryQueueSuccess(data)
    

$( () ->
  window.jug_handler = new JugHandler
)
