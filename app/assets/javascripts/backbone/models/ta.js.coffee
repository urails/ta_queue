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

  # Returns a color hex string, e.g. #293AFF
  hexColor: ->
    window.queue.tas.colors[@color]

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
    count = 0
    _.forEach @models, (model) ->
      model.modelReset()
      model.color = count
      count += 1
  
  # This returns the first TA which is NOT the current_user
  firstTa: () ->
    cu = window.queue.currentUser()
    for ta in @models
      return ta if ta.get('id') != cu.get('id')
    

  url: '/tas'

  colors: ["#FFD873", "#E08484", "#84B1E0", "#E084A9", "#84DCE0", "#DD84E0", "#8984E0"]
