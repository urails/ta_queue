class TaQueue.Model extends Backbone.Model
  toggle: (str) ->
    @set(str, !@get(str))

  action: (action_name, text=null) ->
    $.get("#{@collection.url}/#{@get('id')}/#{action_name}", question: text)


