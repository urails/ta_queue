TaQueue.Views.Tas ||= {}

class TaQueue.Views.Tas.IndexView extends TaQueue.View

  initialize: (options) ->
    super options
    @queue = options.queue
    @bind()

  bind: ->
    @queue.bind "change", @render, @

  render: =>
    return null unless @active
    $(@el).html("")
    @addAll(@queue.tas.models)

  addAll: (tas) ->
    _.each tas, (ta) =>
      @addOne ta

  addOne: (ta) ->
    view = new TaQueue.Views.Tas.ShowView({ ta })
    $(@el).append(view.render().el)
