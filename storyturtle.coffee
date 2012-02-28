###
storyturtle.js
License MIT
http://simplectic.com/story_turtle
###
$ = @jQuery
localStorage = @localStorage

storyturtle = {}
config = {}

$.fn.storyturtle = (options) ->
  config = $.extend true,
    images: {} # Maps image type to URL
    board:
      width: 300
      height: 300
    editor:
      rows: 15
      cols: 30
    controls:
      width: 300
      height: 25
    feature: storyturtle.feature
  , options
  @each ->
    storyturtle.init $(@)

storyturtle.feature = (type, cb) ->
  if type of config.images
    img = new Image()
    img.src = config.images[type]
    $(img).load ->
      feature = $("<img>", src:img.src)
      feature.css
        width:30
        height:30
      cb feature

storyturtle.init = (game) ->
  game.hide()
    .width(
      if config.board.width > config.controls.width
        config.board.width
      else
        config.controls.width)
    .height(config.board.height+config.controls.height)

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

  speaker = $("<div>")
    .width(config.controls.width)
    .height(config.controls.height)
    .appendTo(game)

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

  features = {}
  moveQueue = []
  offset =
    left:0
    top:0

  create = (cb, name, type, x, y) ->
    feature = features[name]
    feature.remove if feature
    config.feature type, (feature) ->
      feature.css
        position: 'absolute'
        left:x
        top:y
      feature.appendTo board
      features[name] = feature
      cb()

  move = (cb, name, x, y)->
    feature = features[name]
    feature and moveQueue.push
      feature: feature
      attrs:
        left:x
        top:y
    cb()

  go = (cb)->
    count = moveQueue.length
    countdown = ->
      cb() unless count--

    toMove = moveQueue.pop()

    while toMove
      toMove.feature.animate(
        toMove.attrs
        1000
        'linear'
        countdown)
      toMove = moveQueue.pop()

    countdown()

  grammer =
    create:
      match: /(\w+)\s+is\s+an?\s+(\w+)\s+at\s+(\d+)\s+(\d+)/
      handle: (match, cb) ->
        create(cb
          match[1]
          match[2]
          parseInt(match[3], 10) + offset.left
          parseInt(match[4], 10) + offset.top)
    die:
      match: /(\w+)\s+dies/
      handle: (match, cb) ->
        feature = features[match[1]]
        feature.remove() if feature
        cb()
    move:
      match: /(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/
      handle: (match, cb)->
        move(
          cb
          match[1]
          parseInt(match[2], 10) + offset.left
          parseInt(match[3], 10) + offset.top)
    pause:
      match: /pause\s+(\d+)/
      handle: (match, cb)->
        setTimeout(cb
          parseInt(match[1], 10) * 10)
    say:
      match: /say\s+(.+)/
      handle: (match, cb)->
        speaker.text match[1]
        cb()
    says:
      match: /(\w+)\s+says\s+(.*)/
      handle: (match, cb)->
        speaker.text "#{match[1]} says, \"#{match[2]}\""
        cb()
    go:
      match: /^\s*$/
      handle: (match, cb)->
        go cb

  parse = (text, cb)->
    features = {}
    moveQueue = []
    board.html ""

    steps = []
    for line in text.split '\n'
      for own key, check of grammer
        match = check.match.exec line
        if match
          steps[steps.length] =
            check: check
            match: match

    idx = 0
    next = ->
      step = steps[idx++]
      if step
        step.check.handle step.match, next
      else
        go cb

    next()

  storage =
    set: (text) ->
      name = game.data "story"
      if name
        localStorage?.setItem "storyturtle_#{name}", text

    get: ->
      name = game.data "story"
      return name and localStorage?.getItem "storyturtle_#{name}"

  if storedGame = storage.get()
    # If we previously stored game, load it
    editor.val(storedGame)

  play.click ->
    board.show()
    editor.hide()
    edit.show()
    controls.hide()
    gameText = editor.val()
    offset = $(board).offset()

    parse gameText, ->
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
