class TaQueue.Routers.QueuesRouter extends Backbone.Router
  initialize: (options) ->
    @queue = window.queue
    window.queue.bind 'change', @updateAll, this

  # This is the default route executed when the queue is visited
  routes:
    "": "index"
  
  index: ->
    console.log "updating all"
    @updateAll()

  updateAll: ->
    @updateCurrentUser()
    @updateUserButtons()
    @view = new TaQueue.Views.Students.IndexView(students: window.queue.students)
    @view.el = $("#queue_list")
    @view.render()

  updateCurrentUser: ->
    if window.user_type == "Student"
      window.current_user = @queue.students.get(window.user_id)
    else
      window.current_user = @queue.tas.get(window.user_id)

  updateUserButtons: ->
    @user_buttons = new TaQueue.Views.Controls.UserButtons(queue: @queue, current_user: window.current_user)
    $("#control_panel").html(@user_buttons.render().el)

