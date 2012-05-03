TaQueue.Views.Chat ||= {}

class TaQueue.Views.Chat.SendMessageView extends Backbone.View
  template: JST["backbone/templates/chat/send_message"]

  events: {
    "keypress input" : "checkEnter"
  }

  checkEnter: (e) ->
    return if (e.keyCode != 13)
    console.log $(@el).find("input").val()
    window.chatsRouter.submitMessage($(@el).find("input").val())
    $(@el).find("input").val("")

  render: ->
    console.log @el
    $(@el).html(@template())

