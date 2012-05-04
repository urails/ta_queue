TaQueue.Views.Chat ||= {}

class TaQueue.Views.Chat.UserView extends Backbone.View
  template: JST["backbone/templates/chat/user"]

  initialize: (options) ->
    window.queue.bind "change", @render, this

  events: {
    "click li" : "userClicked"
  }

  select: (id) ->
    return if @selected == id

    el = @userEl @selected
    el.removeClass "selected"

    @selected = id

    el = $(@el).find("[data-id='#{id}']")
    $(el).addClass("selected")

    # If they were pending, they aren't anymore
    el.removeClass "pending"

  messageReceivedFor: (id) ->
    return if id == @selected

    @userEl(id).addClass "pending"

  userEl: (id) ->
    return $(@el).find("[data-id='#{id}']")

  userClicked: (event) ->
    user_id = $(event.srcElement).attr("data-id")
    window.chatsRouter.navigate "chat/#{user_id}", trigger: true

  render: ->
    $(@el).html("")
    @render_collection "TAs", window.queue.tas.models
    @render_collection "Students", window.queue.students.models

  render_collection: (name, collection) ->
    $(@el).append("<li class=\"header\">#{name}</li>")
    _.each collection, (user) =>
      $(@el).append @template(user: user) if user.get('id') != window.current_user.get('id')
