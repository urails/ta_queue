class TaQueue.Model extends Backbone.Model
  action: (action_name) ->
    $.get("#{@collection.url}/#{@get('id')}/#{action_name}")


