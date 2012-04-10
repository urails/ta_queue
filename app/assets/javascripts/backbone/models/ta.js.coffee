class TaQueue.Models.Ta extends Backbone.Model
  paramRoot: 'ta'

  initialize: (options) ->
    _.bindAll(this, 'url')

  url: ->
    'hello'
    

  defaults:
    username: null
    token: null
    student: null

class TaQueue.Collections.TasCollection extends Backbone.Collection
  model: TaQueue.Models.Ta
  url: '/tas'
