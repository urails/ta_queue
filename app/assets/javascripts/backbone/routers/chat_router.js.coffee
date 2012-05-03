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
    if user = window.queue.tas.firstTa()
      id = user.get('id')
    else if user = window.queue.students.firstStudent()
      id = window.queue.students.firstStudent().get('id')
    @showChatUser id if id
  
  receivedMessage: (id, message) ->
    @messagesView.appendReceivedMessage id, message
    @usersView.messageReceivedFor id

  submitMessage: (message) ->
    $.post("/chats", { to: @usersView.selected, message: message })
    @messagesView.appendClientMessage @usersView.selected, message
  
