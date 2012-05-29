class TaQueue.Routers.ChatsRouter extends Backbone.Router
  initialize: (options) ->
    @initUsersView()
    @initSendMessage()
    @initMessagesView()
    window.events.on "bind:chat", ->
      $('#chat-button').addClass('active')
    window.events.on "unbind:chat", ->
      $('#chat-button').removeClass('active')

  initUsersView: ->
    @usersView = new TaQueue.Views.Chat.UserView
      el: $("#main-left")
      type: "chat"
    #@usersView.render()

  initSendMessage: ->
    @sendMessageView = new TaQueue.Views.Chat.SendMessageView
      el: $("#main-bottom")
      type: "chat"
    #@sendMessageView.render()

  initMessagesView: ->
    @messagesView = new TaQueue.Views.Chat.MessagesView
      el: $("#main-right"),
      selected: @usersView.selected
      type: "chat"

  routes: {
    "chat" : "showChat"
    "chat/:id" : "showChatUser"
  }

  render: ->
    @showChat()

  showChatUser: (id) ->
    @usersView.select id
    @messagesView.render id

  showChat: ->
    window.events.trigger "unbind:queue"
    window.events.trigger "bind:chat"

    @usersView.render()
    @sendMessageView.render()

    if user = window.queue.tas.firstTa()
      id = user.get('id')
    else if user = window.queue.students.firstStudent()
      id = user.get('id')
    @showChatUser id if id
  
  receivedMessage: (id, message) ->
    @messagesView.appendReceivedMessage id, message
    @usersView.messageReceivedFor id

  submitMessage: (message) ->
    $.post("/chats", { to: @usersView.selected, message: message })
    @messagesView.appendClientMessage @usersView.selected, message
  
