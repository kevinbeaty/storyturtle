vows = require 'vows'
assert = require 'assert'
{config} = require '../src/config'
{Actions} = require '../src/actions'

vows
  .describe('Actions Test')
  .addBatch
    'when creating action':
      topic: new Actions()
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
  .export(module)
