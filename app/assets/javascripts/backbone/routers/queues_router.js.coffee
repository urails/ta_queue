class TaQueue.Routers.QueuesRouter extends Backbone.Router
  initialize: (options) ->
    @current_user = options.current_user
    @queue = options.queue
    @view = new TaQueue.Views.Students.IndexView(students: window.queue.students)
    window.queue.bind 'change', @updateAll, this
    @index()

  routes:
    "/":"index"
  
  index: ->
    @updateAll()

  updateAll: ->
    @updateUserButtons()
    $("#queue_panel").append(@view.render().el)

  updateUserButtons: ->
    @user_buttons = new TaQueue.Views.Controls.UserButtons(queue: @queue, current_user: @current_user)
    $("#control_panel").html(@user_buttons.render().el)

