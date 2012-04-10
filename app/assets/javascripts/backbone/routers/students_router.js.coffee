class TaQueue.Routers.StudentsRouter extends Backbone.Router
  initialize: (options) ->

  routes:
    "index": "index"
  
  index: ->
    @view = new TaQueue.Views.Students.IndexView()
    $("#students").html(@view.render().el)

