should = require 'should'
fs = require 'fs'
{parse} = require '../src/parser'
{config} = require '../src/config'
{MockActions} = require './mock/actions'

class FastMockActions extends MockActions
  pause: (time, cb)->
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
          actions.board.should.be.empty
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          done()
    it 'should parse explosions', (done)->
        story 'explosions', (actions)->
          actions.board.should.be.empty
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          done()
    it 'should parse fish', (done)->
        story 'fish', (actions)->
          actions.board.should.have.length 2
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          {speed, red} = actions.features
          should.exist speed
          should.exist red
          speed.left.should.eql 39+actions.offset.left
          speed.top.should.eql 186+actions.offset.top
          red.left.should.eql 42+actions.offset.left
          red.top.should.eql 241+actions.offset.top
          done()
    it 'should parse lizard_catch', (done)->
        story 'lizard_catch', (actions)->
          actions.board.should.have.length 3
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          {queen, fock, berkely, nolan} = actions.features
          should.exist queen
          should.exist fock
          should.exist berkely
          should.not.exist nolan
          queen.left.should.eql 123+actions.offset.left
          queen.top.should.eql 234+actions.offset.top
          fock.left.should.eql 256+actions.offset.left
          fock.top.should.eql 145+actions.offset.top
          berkely.left.should.eql 145+actions.offset.left
          berkely.top.should.eql 123+actions.offset.top
          done()
    it 'should parse shark_bait', (done)->
        story 'shark_bait', (actions)->
          actions.speaker._text.should.eql ""
          actions.board.should.have.length 1
          actions.moveQueue.should.be.empty
          actions.speaker._text.should.eql ""
          {deadly} = actions.features
          should.exist deadly
          deadly.left.should.eql 234+actions.offset.left
          deadly.top.should.eql 213+actions.offset.top
          done()
    it 'should parse turtle_diner', (done)->
        story 'turtle_diner', (actions)->
          actions.speaker._text.should.eql 'silly says, "bye bye bob"'
          actions.board.should.have.length 1
          actions.moveQueue.should.be.empty
          {silly} = actions.features
          silly.left.should.eql 123+actions.offset.left
          silly.top.should.eql 134+actions.offset.top
          done()
    it 'should parse turtle_dinner', (done)->
        story 'turtle_dinner', (actions)->
          actions.speaker._text.should.eql 'greeny says, "yummy!"'
          actions.board.should.have.length 1
          actions.moveQueue.should.be.empty
          {greeny} = actions.features
          greeny.left.should.eql 21+actions.offset.left
          greeny.top.should.eql 152+actions.offset.top
          done()
