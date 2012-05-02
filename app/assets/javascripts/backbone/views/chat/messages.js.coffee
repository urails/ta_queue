TaQueue.Views.Chat ||= {}

class TaQueue.Views.Chat.MessagesView extends Backbone.View
  initialize: (options) ->
    @selected = options.selected

  render: (id) ->
    @selected = id
    $(@el).html(@userDiv(@selected))

  appendClientMessage: (id, message) ->
    @render id
    $(@el).find("table").append("<tr class=\"sent\"><td>#{message}</td></tr>")

  appendReceivedMessage: (id, message) ->
    @render id
    $(@el).find("table").append("<tr class=\"received\"><td>#{message}</td></tr>")

  userDiv: (id) ->
    if data = $.data(@el, id)
      return data
    
    el = $("<table></table>")

    $.data(@el, id, el)

    return el
    
