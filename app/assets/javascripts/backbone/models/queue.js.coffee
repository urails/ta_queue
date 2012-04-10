class TaQueue.Models.Queue extends Backbone.Model
  url: "/queue"

  defaults:
    frozen: null
    active: null
    students: null
    tas: null

#class TaQueue.Collections.QueuesCollection extends Backbone.Collection
  #model: TaQueue.Models.Queue
  #url: '/queues'
