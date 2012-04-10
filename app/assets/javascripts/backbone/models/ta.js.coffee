class TaQueue.Models.Ta extends Backbone.Model
  paramRoot: 'ta'

  initialize: (options) ->
    _.bindAll(this, 'url', 'parse')
    @student = new TaQueue.Models.Student

  parse: (response) ->
    collection = new TaQueue.Collections.StudentsCollection
    console.log "got to parse"
    if response.student
      console.log "got into student conditional"
      collection.reset [response.student]
      @student = collection.first()
    else
      @student = null

  url: ->
    @get 'id'
    

  defaults:
    username: null
    token: null
    student: null

class TaQueue.Collections.TasCollection extends Backbone.Collection
  model: TaQueue.Models.Ta

  initialize: (options) ->
    console.log "got to ta collection"

  url: '/tas'
