{config} = require './config'
{parse} = require './parser'

# Register jquery plugin if in broswer
$ = {}
if jQuery?
  $ = jQuery
  $.fn.storyturtle = (options) ->
    config = $.extend true, config, options
    @each ->
      exports.init $(@)

exports.init = (game) ->
  game.hide()
    .width(Math.max(config.board.width, config.controls.width))
    .height(config.board.height+config.controls.height)
  exports.game = game

  editor = $("<textarea>",
    rows: config.editor.rows
    cols: config.editor.cols)
    .hide()
    .val(game.text())
    .appendTo(game.text(""))

  board = $("<div>")
    .width(config.board.width)
    .height(config.board.height)
    .appendTo(game)
  exports.board = board

  speaker = $("<div>")
    .width(config.controls.width)
    .height(config.controls.height)
    .appendTo(game)
  exports.speaker = speaker

  play = $("<a>", href:'#')
    .text("Play!")
    .css(float: "left")

  edit = $("<a>", href: '#')
    .text("Edit")
    .css(float: "right")

  controls = $("<div>")
    .width(config.controls.width)
    .height(config.controls.height)
    .append(play, edit)
    .appendTo(game)

  storage = exports.storage
  if storedGame = storage.get()
    # If we previously stored game, load it
    editor.val(storedGame)

  play.click ->
    board.show()
    editor.hide()
    edit.show()
    controls.hide()
    gameText = editor.val()
    board.html ""

    parse gameText, config, board, speaker, ->
      speaker.text ""
      controls.show()

    storage.set gameText

    false

  edit.click ->
    board.hide()
    edit.hide()
    editor.show()
    false

  game.show()

exports.storage =
  set: (text) ->
    name = exports.game.data "story"
    if name
      localStorage?.setItem "storyturtle_#{name}", text

  get: ->
    name = exports.game.data "story"
    return name and localStorage?.getItem "storyturtle_#{name}"

