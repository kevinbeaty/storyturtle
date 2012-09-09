{config} = require './config'
context = require './context'
{parse} = require './parser'

$ = jQuery
$.fn.storyturtle = (options) ->
  config = $.extend true, config, options
  @each ->
    init $(@)

init = (game) ->
  game.hide()
    .width(Math.max(config.board.width, config.controls.width))
    .height(config.board.height+config.controls.height)

  editor = $("<textarea>",
    rows: config.editor.rows
    cols: config.editor.cols)
    .hide()
    .val(game.text())
    .appendTo(game.text(""))

  speaker = $("<div>")
    .width(config.controls.width)
    .height(config.controls.height)
    .appendTo(game)
  context.setSpeaker (text)->
    speaker.text text


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
    
  require('./init2')?.init($(game).get(0), config)

  storage = store game
  if storedGame = storage.get()
    # If we previously stored game, load it
    editor.val(storedGame)

  play.click ->
    editor.hide()
    edit.show()
    controls.hide()
    gameText = editor.val()

    parse(gameText).then ->
      speaker.text ""
      controls.show()

    storage.set gameText

    false

  edit.click ->
    edit.hide()
    editor.show()
    false

  game.show()

store = (game)->
  set: (text) ->
    name = game.data "story"
    if name
      localStorage?.setItem "storyturtle_#{name}", text

  get: ->
    name = game.data "story"
    return name and localStorage?.getItem "storyturtle_#{name}"
