{config} = require '../../src/config'
{Actions} = require '../../src/actions'

class MockFeature
  constructor: (@board, @type)->

  css: (css)->
    {@left, @top} = css

  remove: ->
    for f, i in @board
      if @board[i] == @
        @board.splice i, 1

  appendTo: (board)->
    @board.push this

  animate: (attrs, time, easing, cb)->

class MockActions extends Actions
  constructor: (offset={top:10, left:100})->
    super config, [], {text: ""}, offset

  feature: (type, cb)->
    cb new MockFeature @board, type

exports.MockActions = MockActions
