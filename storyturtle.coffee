# storyturtle.js
# License MIT
# http://simplectic.com/story_turtle
$(->
  game = $("#game").hide()
  editor = $("<textarea>", { rows: 15, cols: 30 }).
    hide().val(game.text()).appendTo(game.text(""))
  board = $("<div>").width(300).height(300).appendTo(game)
  speaker = $("<div>").width(350).appendTo(game)
  play = $("<a>", href:'#').text("Play!").css(float: "left")
  edit = $("<a>", href: '#').text("Edit").css(float: "right")
  controls = $("<div>").width(300).append(play, edit).appendTo(game)

  features = {}
  moveQueue = []
  offset = {top: 0, left:0}

  create = (cb, name, type, x, y)->
    feature = features[name]
    feature.remove if feature
    feature = $("<img>", src: "images/#{type}.png")
    feature.css
      position: 'absolute'
      left: x
      top: y
      width: 30
      height: 30
    feature.appendTo board
    features[name] = feature
    cb()

  move = (cb, name, x, y)->
    feature = features[name]
    feature and moveQueue.push
      feature: feature
      attrs: { left: x, top: y }
    cb()

  go = (cb)->
    count = moveQueue.length
    countdown = ->
      cb() unless count--

    toMove = moveQueue.pop()

    while toMove
      toMove.feature.animate(toMove.attrs, 1000, 'linear', countdown)
      toMove = moveQueue.pop()

    countdown()

  grammer =
    create:
      match: /(\w*) is an? (\w*) at (\w*) (\w*)/
      handle: (match, cb) ->
        create(cb,
          match[1],
          match[2],
          parseInt(match[3], 10) + offset.left,
          parseInt(match[4], 10) + offset.top)
    die:
      match: /(\w*) dies/
      handle: (match, cb) ->
        feature = features[match[1]]
        feature.remove() if feature
        cb()
    move:
      match: /(\w*) moves to (\w*) (\w*)/
      handle: (match, cb)->
        move(cb,
          match[1],
          parseInt(match[2], 10) + offset.left,
          parseInt(match[3], 10) + offset.top)
    pause:
      match: /pause (\w*)/
      handle: (match, cb)->
        setTimeout(cb,
        parseInt(match[1], 10) * 10)
    say:
      match: /say (.*)/
      handle: (match, cb)->
        speaker.text match[1]
        cb()
    says:
      match: /(\w*) says (.*)/
      handle: (match, cb)->
        speaker.text "#{match[1]} says, \"#{match[2]}\""
        cb()
    go:
      match: /^(\s*)$/
      handle: (match, cb)->
        go(cb)

  parse = (text, cb)->
    steps = []
    parseLine = (i, line)->
      $.each grammer, (key, check)->
        match = check.match.exec(line)
        if match
          steps[steps.length] = { check: check, match: match }

    idx = 0
    next = ->
      step = steps[idx++]
      if step
        step.check.handle step.match, next
      else
        go(cb)

    features = {}
    moveQueue = []
    board.html("")

    $.each text.split('\n'), parseLine
    next()

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
    false

  edit.click ->
    board.hide()
    edit.hide()
    editor.show()
    false

  game.show()
)
