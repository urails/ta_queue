TaQueue ||= {}

class TaQueue.View extends Backbone.View

  initialize: (options) ->
    window.events.on "unbind:#{options.type}", @becomeInactive, @
    window.events.on "bind:#{options.type}", @becomeActive, @

  becomeActive: ->
    @active = true

  becomeInactive: ->
    @active = false

