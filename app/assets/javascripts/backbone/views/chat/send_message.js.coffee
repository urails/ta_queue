TaQueue.Views.Chat ||= {}

class TaQueue.Views.Chat.SendMessageView extends TaQueue.View
  template: JST["backbone/templates/chat/send_message"]

  initialize: (options) ->
    super options

  events: {
    "keypress input" : "checkEnter"
  }

  checkEnter: (e) ->
    return if (e.keyCode != 13)
    window.chatsRouter.submitMessage($(@el).find("input").val())
    $(@el).find("input").val("")

  render: ->
    return null unless @active
    console.log @el
    $(@el).html(@template())

