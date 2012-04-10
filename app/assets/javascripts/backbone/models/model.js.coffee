class TaQueue.Model extends Backbone.Model
  initialize: (options) ->
    console.log "got to model"

  action: (action_name) ->
    $.get("#{@collection.url}/#{@get('id')}/#{action_name}")


