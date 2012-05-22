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
    if @queue.tas.length > 0
      @addAll(@queue.tas.models)
    else
      $(@el).html("<span class=\"quiet center\" style=\"display:block; margin-top:10px;\">No TAs on duty.</span>")

  addAll: (tas) ->
    _.each tas, (ta) =>
      @addOne ta

  addOne: (ta) ->
    view = new TaQueue.Views.Tas.ShowView({ ta })
    $(@el).append(view.render().el)
