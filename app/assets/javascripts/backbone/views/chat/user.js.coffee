TaQueue.Views.Chat ||= {}

class TaQueue.Views.Chat.UserView extends Backbone.View
  template: JST["backbone/templates/chat/user"]

  initialize: (options) ->

  events: {
    "click td" : "userClicked"
  }

  select: (id) ->
    return if @selected == id
    el = $(@el).find("[data-id='#{@selected}']")
    el.removeClass "selected"

    @selected = id

    el = $(@el).find("[data-id='#{id}']")
    $(el).addClass("selected")
    

  userClicked: (event)->
    user_id = $(event.srcElement).attr("data-id")
    window.chatsRouter.navigate "chat/#{user_id}", trigger: true

  render: ->
    $(@el).html("")
    @render_collection "TAs", window.queue.tas.models
    @render_collection "Students", window.queue.students.models

  render_collection: (name, collection) ->
    $(@el).append("<tr class=\"header\"><th>#{name}</th></tr>")
    _.each collection, (user) =>
      $(@el).append @template(user: user)

