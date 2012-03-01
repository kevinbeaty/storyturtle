vows = require 'vows'
assert = require 'assert'
{config, feature} = require '../storyturtle'

vows
  .describe('Config Test')
  .addBatch
    'when retrieving config':
      topic: config
      'it is defined': (topic)->
        assert.isObject topic
    'when retrieving images':
      topic: config.images
      'it is defined': (topic)->
        assert.isObject topic
    'when retrieving board':
      topic: config.board
      'it is defined': (topic)->
        assert.isObject topic
    'when retrieving board.width':
      topic: config.board.width
      'it is 300': (topic)->
        assert.equal 300, topic
    'when retrieving board.height':
      topic: config.board.height
      'it is 300': (topic)->
        assert.equal 300, topic
    'when retrieving editor':
      topic: config.editor
      'it is defined': (topic)->
        assert.isObject topic
    'when getting editor.cols':
      topic: config.editor.cols
      'it is 30': (topic)->
        assert.equal topic, 30
    'when getting editor.rows':
      topic: config.editor.rows
      'it is 15': (topic)->
        assert.equal topic, 15
     'when retrieving controls':
      topic: config.controls
      'it is defined': (topic)->
        assert.isObject topic
    'when retrieving controls.width':
      topic: config.controls.width
      'it is 300': (topic)->
        assert.equal 300, topic
      'it is same as board width': (topic)->
        assert.equal config.board.width, topic
    'when retrieving controls.height':
      topic: config.controls.height
      'it is 25': (topic)->
        assert.equal 25, topic
    'when retrieving feature':
      topic: ->
        return config.feature
      'it is a function': (topic)->
        assert.isFunction topic
      'it is same as feature': (topic)->
        assert.equal topic, feature
  .export(module)
