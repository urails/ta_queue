TaQueue.Views.Tas ||= {}

class TaQueue.Views.Tas.IndexView extends Backbone.View
  initialize: (options) ->
    @queue = options.queue
    @queue.bind "change", @render, @

  render: ->
    $(@el).html("")
    @addAll(@queue.tas.models)

  addAll: (tas) ->
    _.each tas, (ta) =>
      @addOne ta

  addOne: (ta) ->
    view = new TaQueue.Views.Tas.ShowView({ ta })
    $(@el).append(view.render().el)
