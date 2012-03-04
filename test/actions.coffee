should = require 'should'
{config} = require '../src/config'
{Actions} = require '../src/actions'
{MockActions} = require './mock/actions'

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

  describe 'create and die', ->
    it 'should add bob', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        {bob} = actions.features
        should.exist bob
        actions.board.should.include bob
        bob.left.should.eql 12+actions.offset.left
        bob.top.should.eql 13+actions.offset.top
        done()
    it 'should add frank but remove bob when bob dies', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        actions.create 'frank', 'cat', 48, 81, ->
          actions.die 'bob', ->
            {bob, frank} = actions.features
            should.not.exist bob
            should.exist frank
            actions.board.should.include frank
            frank.left.should.eql 48+actions.offset.left
            frank.top.should.eql 81+actions.offset.top
            done()
  describe 'create, move and go', ->
    it 'should move bob', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        actions.move 'bob', 32, 33, ->
          actions.go ->
            {bob} = actions.features
            should.exist bob
            actions.board.should.include bob
            bob.left.should.eql 32+actions.offset.left
            bob.top.should.eql 33+actions.offset.top
            done()
    it 'should move bob and frank', (done)->
      actions = new MockActions
      actions.create 'bob', 'dog', 12, 13, ->
        actions.create 'frank', 'cat', 48, 81, ->
          actions.move 'bob', 32, 33, ->
            actions.move 'frank', 118, 191, ->
              actions.go ->
                {bob, frank} = actions.features
                should.exist bob
                should.exist frank
                actions.board.should.include bob
                actions.board.should.include frank
                bob.left.should.eql 32+actions.offset.left
                bob.top.should.eql 33+actions.offset.top
                frank.left.should.eql 118+actions.offset.left
                frank.top.should.eql 191+actions.offset.top
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

