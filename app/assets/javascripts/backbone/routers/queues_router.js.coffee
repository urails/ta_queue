class TaQueue.Routers.QueuesRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    "show": "show"
  
  show: ->
    @view = new TaQueue.Views.Queues.ShowView()
    $("#queues").html(@view.render().el)

