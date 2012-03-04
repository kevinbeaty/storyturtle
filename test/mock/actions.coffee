{config} = require '../../src/config'
{Actions} = require '../../src/actions'

class MockFeature
  constructor: (@board, @type)->
    @_css = {}

  css: (css)->
    @_css = css 

  remove: ->
    @board.remove this

  appendTo: (board)->
    @board.push this

  animate: (attrs, time, easing, cb)->
    
class MockActions extends Actions
  constructor: (offset={top:0, left:0})->
    super config, [], {text: ""}, offset

  feature: (type, cb)->
    cb new MockFeature @board, type

exports.MockActions = MockActions
