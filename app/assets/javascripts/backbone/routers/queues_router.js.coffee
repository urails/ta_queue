class TaQueue.Routers.QueuesRouter extends Backbone.Router
  initialize: (options) ->
    @queue = window.queue
    @initStudentsView()
    @initTasView()
    @initUserButtons()
    @initQueueStatus()
    @userButtons.centerControlBar()
    window.events.on "bind:queue", ->
      $('#queue-button').addClass('active')
    window.events.on "unbind:queue", ->
      $('#queue-button').removeClass('active')

  # This is the default route executed when the queue is visited
  routes:
    "": "index"
  
  index: =>
    @render()

  #unbind: ->
    #@studentsView.remove()
    #@tasView.remove()
    #@queueStatus.remove()
    #@userButtons.remove()

  render: ->
    window.events.trigger "unbind:chat"
    window.events.trigger "bind:queue"
    #@studentsView.el = $("#main-right")
    @studentsView.render()

    @tasView.render()

    @queueStatus.render()

    @userButtons.render()

  initStudentsView: ->
    @studentsView = new TaQueue.Views.Students.IndexView
      students: window.queue.students
      el: $("#main-right")
      type: "queue"
    #@studentsView.render()
  
  initTasView: ->
    @tasView = new TaQueue.Views.Tas.IndexView
      queue: window.queue
      el: $("#main-left")
      type: "queue"
    #@tasView.render()

  initQueueStatus: ->
    @queueStatus = new TaQueue.Views.Controls.StatusUpdateShowView
      queue: window.queue
      el: $("#queue-status")
      type: "queue"
    #@queue_status.render()

  initUserButtons: ->
    @userButtons = new TaQueue.Views.Controls.UserButtons
      queue: @queue
      current_user: window.queue.currentUser()
      el: $("#main-bottom")
      type: "queue"
    #@user_buttons.render()
