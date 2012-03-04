should = require 'should'
{config} = require '../src/config'
{Actions} = require '../src/actions'
{MockActions} = require './mock/actions'

threadActions = (steps, cb)->
  actions = new MockActions
  idx = 0
  next = (steps)->
    step = steps[idx++]
    if step?
      params = step[1...]
      params[params.length] = next
      actions[step[0]].apply actions, params
    else
      cb actions
  next steps

describe 'Actions Test', ->
  describe 'creating action', ->
    it 'exists', ->
      should.exist new Actions
    it 'has offset', ->
      actions = new Actions
      should.exist actions.offset
      actions.offset.left.should.eql 0
      actions.offset.top.should.eql 0
    it 'has features', ->
      actions = new Actions
      should.exist actions.features
    it 'has moveQueue that is empty', ->
      actions = new Actions
      should.exist actions.moveQueue
      actions.moveQueue.should.be.empty
    it 'all methods defined', ->
      actions = new Actions
      for f in ['create', 'die', 'move', 'go', 'pause', 'say', 'says']
        actions[f].should.be.a 'function'
  describe 'creating mock action', ->
    it 'is Actions', ->
      actions = new MockActions
      actions.should.be.an.instanceof Actions
    it 'has offset', ->
      actions = new MockActions
      should.exist actions.offset
      actions.offset.left.should.eql 100
      actions.offset.top.should.eql 10
    it 'features', ->
      actions = new MockActions
      should.exist actions.features
    it 'has moveQueue that is empty', ->
      actions = new MockActions
      should.exist actions.moveQueue
      actions.moveQueue.should.be.empty
    it 'all methods defined', ->
      actions = new MockActions
      for f in ['create', 'die', 'move', 'go', 'pause', 'say', 'says']
        actions[f].should.be.a 'function'

  describe 'create bob', ->
    it 'should add bob', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        bob = actions.features['bob']
        should.exist bob
        actions.board.should.include bob
        bob.left.should.eql 12+actions.offset.left
        bob.top.should.eql 13+actions.offset.top
        done()
  describe 'create bob and frank and bob dies', ->
    it 'should add frank', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        actions.create 'frank', 'cat', 48, 81, ->
          actions.die 'bob', ->
            bob = actions.features['bob']
            frank = actions.features['frank']
            should.not.exist bob
            should.exist frank
            actions.board.should.include frank
            frank.left.should.eql 48+actions.offset.left
            frank.top.should.eql 81+actions.offset.top
            done()
