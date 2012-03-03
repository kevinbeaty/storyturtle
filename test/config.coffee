vows = require 'vows'
assert = require 'assert'
{config} = require '../src/config'

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
      'board is defined': (topic)->
        assert.isObject topic
      'width is 300': (topic)->
        assert.equal 300, topic.width
      'height is 300': (topic)->
        assert.equal 300, topic.height
    'when retrieving editor':
      topic: config.editor
      'editor is defined': (topic)->
        assert.isObject topic
      'cols is 30': (topic)->
        assert.equal topic.cols, 30
      'rows is 15': (topic)->
        assert.equal topic.rows, 15
    'when retrieving controls':
      topic: config.controls
      'controls is defined': (topic)->
        assert.isObject topic
      'width is 300': (topic)->
        assert.equal 300, topic.width
      'width is same as board width': (topic)->
        assert.equal config.board.width, topic.width
      'height is 25': (topic)->
        assert.equal 25, topic.height
  .export(module)
