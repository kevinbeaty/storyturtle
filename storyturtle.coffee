###
storyturtle.js
License MIT
http://simplectic.com/story_turtle
###
self = if exports? then exports else {}

self.features = {}
self.moveQueue = []
self.offset =
    left:0
    top:0

self.config =
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

self.feature = (type, cb) ->
  config = self.config
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
self.config.feature = self.feature

$ = @jQuery
if $
  # Register jquery plugin if in broswer
  $.fn.storyturtle = (options) ->
    self.config = $.extend true, self.config, options
    self.feature = self.config.feature or self.feature
    @each ->
      self.init $(@)

self.init = (game) ->
  config = self.config
  game.hide()
    .width(Math.max(config.board.width, config.controls.width))
    .height(config.board.height+config.controls.height)
  self.game = game

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
  self.board = board

  speaker = $("<div>")
    .width(config.controls.width)
    .height(config.controls.height)
    .appendTo(game)
  self.speaker = speaker

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

  storage = self.storage
  if storedGame = storage.get()
    # If we previously stored game, load it
    editor.val(storedGame)

  play.click ->
    board.show()
    editor.hide()
    edit.show()
    controls.hide()
    gameText = editor.val()
    self.offset = $(board).offset()
    board.html ""

    self.parse gameText, ->
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

localStorage = @localStorage
self.storage =
  set: (text) ->
    name = self.game.data "story"
    if name
      localStorage?.setItem "storyturtle_#{name}", text

  get: ->
    name = self.game.data "story"
    return name and localStorage?.getItem "storyturtle_#{name}"

self.parse = (text, cb)->
  self.features = {}
  self.moveQueue = []

  steps = []
  for line in text.split '\n'
    for own key, check of self.grammer
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
      self.go cb

  next()

self.create = (cb, name, type, x, y) ->
  feature = self.features[name]
  feature.remove if feature
  self.feature type, (feature) ->
    feature.css
      position: 'absolute'
      left:x
      top:y
    feature.appendTo self.board
    self.features[name] = feature
    cb()

self.move = (cb, name, x, y)->
  feature = self.features[name]
  feature and self.moveQueue.push
    feature: feature
    attrs:
      left:x
      top:y
  cb()

self.go = (cb)->
  count = self.moveQueue.length
  countdown = ->
    cb() unless count--

  toMove = self.moveQueue.pop()

  while toMove
    toMove.feature.animate(
      toMove.attrs
      1000
      'linear'
      countdown)
    toMove = self.moveQueue.pop()

  countdown()

self.grammer =
  create:
    match: /(\w+)\s+is\s+an?\s+(\w+)\s+at\s+(\d+)\s+(\d+)/
    handle: (match, cb) ->
      offset = self.offset
      self.create(cb
        match[1]
        match[2]
        parseInt(match[3], 10) + offset.left
        parseInt(match[4], 10) + offset.top)
  die:
    match: /(\w+)\s+dies/
    handle: (match, cb) ->
      feature = self.features[match[1]]
      feature.remove() if feature
      cb()
  move:
    match: /(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/
    handle: (match, cb)->
      offset = self.offset
      self.move(
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
      self.speaker.text match[1]
      cb()
  says:
    match: /(\w+)\s+says\s+(.*)/
    handle: (match, cb)->
      self.speaker.text "#{match[1]} says, \"#{match[2]}\""
      cb()
  go:
    match: /^\s*$/
    handle: (match, cb)->
      self.go cb
