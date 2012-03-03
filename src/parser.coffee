{ create
  die
  move
  go
  pause
  say
  says
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
      [_, name, type, x, y] = match
      create cb, context,
        name
        type
        parseInt(x, 10) + offset.left
        parseInt(y, 10) + offset.top
  die:
    match: /(\w+)\s+dies/
    handle: (cb, context, match) ->
      [_, name] = match
      die cb, context, name
  move:
    match: /(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/
    handle: (cb, context, match)->
      {offset} = context
      [_, name, x, y] = match
      move cb, context,
        name
        parseInt(x, 10) + offset.left
        parseInt(y, 10) + offset.top
  pause:
    match: /pause\s+(\d+)/
    handle: (cb, context, match)->
      [_, time] = match
      pause cb, context, parseInt(time, 10) * 10
  say:
    match: /say\s+(.+)/
    handle: (cb, context, match)->
      {speaker} = context
      [_, text] = match
      say cb, context, text
  says:
    match: /(\w+)\s+says\s+(.*)/
    handle: (cb, context, match)->
      {speaker} = context
      [_, name, text] = match
      says cb, context, name, text
  go:
    match: /^\s*$/
    handle: (cb, context, match)->
      go cb, context

exports.parse = parse
exports.grammer = grammer
