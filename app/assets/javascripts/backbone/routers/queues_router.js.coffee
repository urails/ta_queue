class TaQueue.Routers.QueuesRouter extends Backbone.Router
  initialize: (options) ->
    @current_user = options.current_user
    @queue = options.queue
    console.log 'initialized router'
    @view = new TaQueue.Views.Students.IndexView(students: window.queue.students)
    @user_buttons = new TaQueue.Views.Controls.UserButtons(queue: @queue, current_user: @current_user)
    window.queue.bind 'change', @updateAll, this
    @index()

  routes:
    "/":"index"
  
  index: ->
    @updateAll()

  updateAll: ->
    console.log 'updating all'
    @updateUserButtons()
    $("#queue_panel").append(@view.render().el)

  updateUserButtons: ->
    $("#control_panel").html(@user_buttons.render().el)

