class TaQueue.Routers.ChatsRouter extends Backbone.Router
  initialize: (options) ->
    @initUsersView()
    @initSendMessage()
    @initMessagesView()

  initUsersView: ->
    @usersView = new TaQueue.Views.Chat.UserView( el: $("#chat_list"))
    @usersView.render()

  initSendMessage: ->
    @sendMessageView = new TaQueue.Views.Chat.SendMessageView( el: $("#send_message"))
    @sendMessageView.render()

  initMessagesView: ->
    @messagesView = new TaQueue.Views.Chat.MessagesView( el: $("#messages"), selected: @usersView.selected)


  routes: {
    "chat" : "showChat"
    "chat/:id" : "showChatUser"
  }

  showChatUser: (id) ->
    @usersView.select id
    @messagesView.render id

  showChat: ->
    @usersView.select window.queue.tas.first().get('id')
  
  receivedMessage: (id, message) ->
    @messagesView.appendReceivedMessage id, message

  submitMessage: (message) ->
    $.post("/chats", { to: @usersView.selected, message: message })
    @messagesView.appendClientMessage @usersView.selected, message
  
