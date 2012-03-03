{feature} = require './feature'

parse = (text, config, board, speaker, cb)->
  context = 
    config: config
    board: board
    speaker: speaker
    offset: board.offset()
    features: {}
    moveQueue: []

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
      step.check.handle next, context, step.match
    else
      go cb, context

  next()

create = (cb, context, name, type, x, y) ->
  {features, board, config} = context

  f = features[name]
  f.remove if f
  feature type, config, (f) ->
    f.css
      position: 'absolute'
      left:x
      top:y
    f.appendTo board
    features[name] = f
    cb()

move = (cb, context, name, x, y)->
  {features, moveQueue} = context

  f = features[name]
  f and moveQueue.push
    feature: f
    attrs:
      left:x
      top:y
  cb()

go = (cb, context)->
  {moveQueue} = context

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
    handle: (cb, context, match) ->
      {offset} = context 
      create(cb, context,
        match[1]
        match[2]
        parseInt(match[3], 10) + offset.left
        parseInt(match[4], 10) + offset.top)
  die:
    match: /(\w+)\s+dies/
    handle: (cb, context, match) ->
      {features} = context
      f = features[match[1]]
      f.remove() if f
      cb()
  move:
    match: /(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/
    handle: (cb, context, match)->
      {offset} = context 
      move(
        cb, context,
        match[1]
        parseInt(match[2], 10) + offset.left
        parseInt(match[3], 10) + offset.top)
  pause:
    match: /pause\s+(\d+)/
    handle: (cb, context, match)->
      setTimeout(cb
        parseInt(match[1], 10) * 10)
  say:
    match: /say\s+(.+)/
    handle: (cb, context, match)->
      {speaker} = context
      speaker.text match[1]
      cb()
  says:
    match: /(\w+)\s+says\s+(.*)/
    handle: (cb, context, match)->
      {speaker} = context
      speaker.text "#{match[1]} says, \"#{match[2]}\""
      cb()
  go:
    match: /^\s*$/
    handle: (cb, context, match)->
      go cb, context

exports.parse = parse
exports.grammer = grammer
