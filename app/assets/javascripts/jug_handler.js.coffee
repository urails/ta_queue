class JugHandler
  start_juggernaut: () ->
    window.board_title = $('#board_title').val()
    jug = new Juggernaut
    jug.subscribe "#{window.board_title}/queue", (data) ->
      console.log data
      window.queue.set($.parseJSON(data))
      #queue.queryQueueSuccess($.parseJSON(data))
    

$(document).ready () ->
  if window.jug_handler == undefined
    window.jug_handler = new JugHandler
    window.jug_handler.start_juggernaut()
