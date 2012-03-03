{ create
  move
  go
} = require './actions'

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
