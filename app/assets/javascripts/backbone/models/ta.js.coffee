class TaQueue.Models.Ta extends Backbone.Model
  paramRoot: 'ta'

  isTa: true
  isStudent: false

  initialize: (options) ->
    _.bindAll(this, 'url', 'parse', 'modelReset')
    @student = new TaQueue.Models.Student
    @bind 'reset', @modelReset, this

  modelReset: (collection) ->
    @student.set(@get('student'))

  url: ->
    @get 'id'
    

  defaults:
    username: null
    token: null
    student: null

class TaQueue.Collections.TasCollection extends Backbone.Collection
  model: TaQueue.Models.Ta

  initialize: (options) ->
    _.bindAll(this, 'collectionReset')
    @bind 'reset', @collectionReset, this

  collectionReset: (collection) ->
    _.forEach @models, (model) ->
      model.modelReset()
    

  url: '/tas'
