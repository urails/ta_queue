class TaQueue.Routers.QueuesRouter extends Backbone.Router
  initialize: (options) ->
    @queue = window.queue
    @initStudentsView()
    @initTasView()
    @initUserButtons()
    @initQueueStatus()
    @userButtons.centerControlBar()

  # This is the default route executed when the queue is visited
  routes:
    "": "index"
  
  index: ->
    @render()

  #unbind: ->
    #@studentsView.remove()
    #@tasView.remove()
    #@queueStatus.remove()
    #@userButtons.remove()

  render: ->
    @studentsView.bind()
    @studentsView.render()

    @tasView.bind()
    @tasView.render()

    @queueStatus.bind()
    @queueStatus.render()

    @userButtons.bind()
    @userButtons.render()

  initStudentsView: ->
    @studentsView = new TaQueue.Views.Students.IndexView
      students: window.queue.students
      el: $("#main-right")
    #@studentsView.render()
  
  initTasView: ->
    @tasView = new TaQueue.Views.Tas.IndexView
      queue: window.queue
      el: $("#main-left")
    #@tasView.render()

  initQueueStatus: ->
    @queueStatus = new TaQueue.Views.Controls.StatusUpdateShowView
      queue: window.queue
      el: $("#queue-status")
    #@queue_status.render()

  initUserButtons: ->
    @userButtons = new TaQueue.Views.Controls.UserButtons
      queue: @queue
      current_user: window.queue.currentUser()
      el: $("#main-bottom")
    #@user_buttons.render()
