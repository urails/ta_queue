class iOSJugHandler
  
  start: ->
    jug = new Juggernaut

    jug.subscribe "queue/#{window.queue_id}", (data) ->
      console.log data
      window.location = data

$ ->
  window.jug_handler = new iOSJugHandler()
  window.jug_handler.start()

