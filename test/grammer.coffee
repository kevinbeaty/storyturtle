vows = require 'vows'
assert = require 'assert'

{grammer:{
  create
  die
  move
  pause
  say
  says
  go
}} = require '../storyturtle'

vows
  .describe('Grammer Test')
  .addBatch
    'when matching create':
      topic: create 
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
    'when matching die':
      topic: die 
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
    'when matching move':
      topic: move 
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
    'when matching pause':
      topic: pause 
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
    'when matching say':
      topic: say 
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
    'when matching says':
      topic: says 
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
    'when matching go':
      topic: go 
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
  .export(module)
