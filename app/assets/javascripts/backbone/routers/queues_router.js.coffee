class TaQueue.Routers.QueuesRouter extends Backbone.Router
  initialize: (options) ->
    @queue = window.queue
    @initStudentsView()
    @initTasView()
    @initCurrentUser()
    @initUserButtons()
    @initQueueStatus()
    @user_buttons.centerControlBar()

  # This is the default route executed when the queue is visited
  routes:
    "": "index"
  
  index: ->
    console.log "got here"

  initStudentsView: ->
    @studentsView = new TaQueue.Views.Students.IndexView
      students: window.queue.students
      el: $("#queue_list")
    @studentsView.render()
  
  initTasView: ->
    @tasView = new TaQueue.Views.Tas.IndexView
      queue: window.queue
      el: $("#tas_in_queue")
    @tasView.render()

  initQueueStatus: ->
    @queue_status = new TaQueue.Views.Controls.StatusUpdateShowView
      queue: window.queue
      el: $("#queue_status")
    @queue_status.render()

  initCurrentUser: ->
    if window.user_type == "Student"
      window.current_user = @queue.students.get(window.user_id)
    else
      window.current_user = @queue.tas.get(window.user_id)

  initUserButtons: ->
    @user_buttons = new TaQueue.Views.Controls.UserButtons
      queue: @queue
      current_user: window.current_user
      el: $("#control_bar")
    @user_buttons.render()
