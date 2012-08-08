should = require 'should'
{config} = require '../src/config'
context = require '../src/context'
{Actions} = require '../src/actions'
{MockActions} = require './mock/actions'

describe 'Actions Test', ->
  describe 'creating action', ->
    it 'exists', ->
      should.exist new Actions
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
    it 'has moveQueue that is empty', ->
      actions = new MockActions
      should.exist actions.moveQueue
      actions.moveQueue.should.be.empty
    it 'all methods defined', ->
      actions = new MockActions
      for f in ['create', 'die', 'move', 'go', 'pause', 'say', 'says']
        actions[f].should.be.a 'function'

  describe 'create and die', ->
    it 'should add bob', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        bob = context.feature('bob') 
        should.exist bob
        bob.x.should.eql 12
        bob.y.should.eql 13
        done()
    it 'should add frank but remove bob when bob dies', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        actions.create 'frank', 'cat', 48, 81, ->
          actions.die 'bob', ->
            bob = context.feature('bob')
            frank = context.feature('frank')
            should.not.exist bob
            should.exist frank
            frank.x.should.eql 48
            frank.y.should.eql 81
            done()
  describe 'create, move and go', ->
    it 'should move bob', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        actions.move 'bob', 32, 33, ->
          actions.go ->
            bob = context.feature('bob')
            should.exist bob
            bob.x.should.eql 32
            bob.y.should.eql 33
            done()
    it 'should move bob and frank', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        actions.create 'frank', 'cat', 48, 81, ->
          actions.move 'bob', 32, 33, ->
            actions.move 'frank', 118, 191, ->
              actions.go ->
                bob = context.feature('bob')
                frank = context.feature('frank')
                should.exist bob
                should.exist frank
                bob.x.should.eql 32
                bob.y.should.eql 33
                frank.x.should.eql 118
                frank.y.should.eql 191
                done()
  describe 'pause', ->
    it 'should complete', (done)->
      actions = new MockActions
      actions.pause 1, done
  describe 'say and says', ->
    it 'should say "hello bob"', (done)->
      actions = new MockActions
      actions.say "hello bob", ->
        actions.speaker._text.should.equal "hello bob"
        done()
    it 'should say frank says "hello bob"', (done)->
      actions = new MockActions
      actions.says "frank", "hello bob", ->
        actions.speaker._text.should.equal 'frank says, "hello bob"'
        done()

