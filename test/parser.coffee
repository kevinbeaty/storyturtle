should = require 'should'
fs = require 'fs'
{parse} = require '../src/parser'
{config} = require '../src/config'
context = require '../src/context'
{MockActions} = require './mock/actions'

class FastMockActions extends MockActions
  pause: (time, cb)->
    cb()
  animate: (features, cb)->
    for f in features
      f.feature.position(f.x2, f.y2)
    cb()

story = (name, cb)->
  actions = new FastMockActions
  game = ""+ fs.readFileSync "#{__dirname}/stories/#{name}.txt"
  parse game, actions, ->
    cb actions

describe 'Parser Test', ->
  describe 'parse stories', ->
    it 'should parse dessert_shark', (done)->
        story 'dessert_shark', (actions)->
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          done()
    it 'should parse explosions', (done)->
        story 'explosions', (actions)->
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          done()
    it 'should parse fish', (done)->
        story 'fish', (actions)->
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          speed = context.feature('speed')
          red = context.feature('red')
          should.exist speed
          should.exist red
          speed.x.should.eql 39
          speed.y.should.eql 186
          red.x.should.eql 42
          red.y.should.eql 241
          done()
    it 'should parse lizard_catch', (done)->
        story 'lizard_catch', (actions)->
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          queen = context.feature('queen')
          fock = context.feature('fock')
          berkely = context.feature('berkely')
          nolan = context.feature('nolan')
          should.exist queen
          should.exist fock
          should.exist berkely
          should.not.exist nolan
          queen.x.should.eql 123
          queen.y.should.eql 234
          fock.x.should.eql 256
          fock.y.should.eql 145
          berkely.x.should.eql 145
          berkely.y.should.eql 123
          done()
    it 'should parse shark_bait', (done)->
        story 'shark_bait', (actions)->
          actions.speaker._text.should.eql ""
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          deadly = context.feature('deadly')
          should.exist deadly
          deadly.x.should.eql 234
          deadly.y.should.eql 213
          done()
    it 'should parse turtle_diner', (done)->
        story 'turtle_diner', (actions)->
          actions.speaker._text.should.eql 'silly says, "bye bye bob"'
          actions.moveQueue.should.be.empty
          silly = context.feature('silly')
          silly.x.should.eql 123
          silly.y.should.eql 134
          done()
    it 'should parse turtle_dinner', (done)->
        story 'turtle_dinner', (actions)->
          actions.speaker._text.should.eql 'greeny says, "yummy!"'
          actions.moveQueue.should.be.empty
          greeny = context.feature('greeny')
          greeny.x.should.eql 21
          greeny.y.should.eql 152
          done()
