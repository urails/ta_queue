class App.Questions extends Spine.Controller
  # elements:
  #   '.items': items
  # 
  # events:
  #   'click .item': 'itemClick'

  constructor: ->
    super
    @questions = App.Question.all()
