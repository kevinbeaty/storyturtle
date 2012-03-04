vows = require 'vows'
assert = require 'assert'
{config} = require '../src/config'
{Actions} = require '../src/actions'
{MockActions} = require './mock/actions'

vows
  .describe('Actions Test')
  .addBatch
    'when creating action':
      topic: ()-> new Actions()
      'it is defined': (topic)->
        assert.isObject topic
      'offset is defined': (topic)->
        assert.isObject topic.offset
      'features is object': (topic)->
        assert.isObject topic.features
      'features is empty': (topic)->
        assert.isFalse not topic.features
      'moveQueue is array': (topic)->
        assert.isArray topic.moveQueue
      'moveQueue is empty': (topic)->
        assert.equal topic.moveQueue.length, 0
      'methods are defined': (topic)->
        for f in ['create', 'die', 'move', 'go', 'pause', 'say', 'says']
          assert.isFunction topic[f]
    'when creating mock action':
      topic: ()-> new MockActions()
      'it is defined': (topic)->
        assert.isObject topic
      'it is an action': (topic)->
        assert.instanceOf topic, Actions
      'offset is defined': (topic)->
        assert.isObject topic.offset
      'features is object': (topic)->
        assert.isObject topic.features
      'features is empty': (topic)->
        assert.isFalse not topic.features
      'moveQueue is array': (topic)->
        assert.isArray topic.moveQueue
      'moveQueue is empty': (topic)->
        assert.equal topic.moveQueue.length, 0
      'methods are defined': (topic)->
        for f in ['create', 'die', 'move', 'go', 'pause', 'say', 'says']
          assert.isFunction topic[f]
  .export(module)
