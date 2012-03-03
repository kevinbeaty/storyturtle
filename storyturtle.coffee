exports.features = {}
exports.moveQueue = []
exports.offset =
    left:0
    top:0

exports.config =
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

exports.feature = (type, cb) ->
  config = exports.config
  if type of config.images
    img = new Image()
    img.src = config.images[type]
    $(img).load ->
      dim = config.board.width / 10
      width = img.width or dim
      height = img.height or dim
      scale = dim/height
      width *= scale
      height *= scale
      feature = $("<img>", src:img.src)
      feature.css
        width:width
        height:height
      cb feature
exports.config.feature = exports.feature

# Register jquery plugin if in broswer
$ = {}
if jQuery?
  $ = jQuery
  $.fn.storyturtle = (options) ->
    exports.config = $.extend true, exports.config, options
    exports.feature = exports.config.feature or exports.feature
    @each ->
      exports.init $(@)

exports.init = (game) ->
  config = exports.config
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
    exports.offset = $(board).offset()
    board.html ""

    exports.parse gameText, ->
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

exports.parse = (text, cb)->
  exports.features = {}
  exports.moveQueue = []

  steps = []
  for line in text.split '\n'
    for own key, check of exports.grammer
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
      exports.go cb

  next()

exports.create = (cb, name, type, x, y) ->
  feature = exports.features[name]
  feature.remove if feature
  exports.feature type, (feature) ->
    feature.css
      position: 'absolute'
      left:x
      top:y
    feature.appendTo exports.board
    exports.features[name] = feature
    cb()

exports.move = (cb, name, x, y)->
  feature = exports.features[name]
  feature and exports.moveQueue.push
    feature: feature
    attrs:
      left:x
      top:y
  cb()

exports.go = (cb)->
  count = exports.moveQueue.length
  countdown = ->
    cb() unless count--

  toMove = exports.moveQueue.pop()

  while toMove
    toMove.feature.animate(
      toMove.attrs
      1000
      'linear'
      countdown)
    toMove = exports.moveQueue.pop()

  countdown()

exports.grammer =
  create:
    match: /(\w+)\s+is\s+an?\s+(\w+)\s+at\s+(\d+)\s+(\d+)/
    handle: (match, cb) ->
      offset = exports.offset
      exports.create(cb
        match[1]
        match[2]
        parseInt(match[3], 10) + offset.left
        parseInt(match[4], 10) + offset.top)
  die:
    match: /(\w+)\s+dies/
    handle: (match, cb) ->
      feature = exports.features[match[1]]
      feature.remove() if feature
      cb()
  move:
    match: /(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/
    handle: (match, cb)->
      offset = exports.offset
      exports.move(
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
      exports.speaker.text match[1]
      cb()
  says:
    match: /(\w+)\s+says\s+(.*)/
    handle: (match, cb)->
      exports.speaker.text "#{match[1]} says, \"#{match[2]}\""
      cb()
  go:
    match: /^\s*$/
    handle: (match, cb)->
      exports.go cb
