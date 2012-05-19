class TaQueue.Routers.ChatsRouter extends Backbone.Router
  initialize: (options) ->
    @initUsersView()
    @initSendMessage()
    @initMessagesView()

  initUsersView: ->
    @usersView = new TaQueue.Views.Chat.UserView
      el: $("#main-left")
    #@usersView.render()

  initSendMessage: ->
    @sendMessageView = new TaQueue.Views.Chat.SendMessageView
      el: $("#main-bottom")
    #@sendMessageView.render()

  initMessagesView: ->
    @messagesView = new TaQueue.Views.Chat.MessagesView
      el: $("#main-right"),
      selected: @usersView.selected

  #unbind: ->
    #@usersView.unbind()
    #@sendMessageView.unbind()
    #@messagesView.unbind()


  routes: {
    "chat" : "showChat"
    "chat/:id" : "showChatUser"
  }

  render: ->
    @showChat()
    #@usersView.render()
    #@sendMessageView.render()
    #@messagesView.render()
    #@showChat()

  showChatUser: (id) ->
    @usersView.select id

    @usersView.bind()
    @usersView.render()

    @messagesView.bind()
    @messagesView.render id

    @sendMessageView.bind()
    @sendMessageView.render()

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
  
