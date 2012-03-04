should = require 'should'
{config} = require '../src/config'

describe 'Config Test', ->
  describe 'config', ->
    it 'exists', ->
      should.exist config
  describe 'images', ->
    it 'exists', ->
      should.exist config
  describe 'board', ->
    it 'exists', ->
      should.exist config.board
    it 'has width of 300', ->
      config.board.width.should.eql 300
    it 'has height of 300', ->
      config.board.height.should.eql 300
  describe 'editor', ->
    it 'exists', ->
      should.exist config.editor
    it 'has cols of 30', ->
      config.editor.cols.should.eql 30
    it 'has rows of 15', ->
      config.editor.rows.should.eql 15
  describe 'controls', ->
    it 'exists', ->
      should.exist config.controls
    it 'has width of 300', ->
      config.controls.width.should.eql 300
    it 'width is same as board width', ->
      config.board.width.should.eql config.controls.width
    it 'height is 25', ->
      config.controls.height.should.eql 25
