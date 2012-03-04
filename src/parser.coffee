parse = (text, actions, cb)->
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
      step.check.handle step.match, actions, next
    else
      actions.go cb

  next()

grammer =
  create:
    match: /(\w+)\s+is\s+an?\s+(\w+)\s+at\s+(\d+)\s+(\d+)/
    handle: (match, actions, cb) ->
      [_, name, type, x, y] = match
      actions.create name, type, parseInt(x, 10), parseInt(y, 10), cb
  die:
    match: /(\w+)\s+dies/
    handle: (match, actions, cb) ->
      [_, name] = match
      actions.die name, cb
  move:
    match: /(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/
    handle: (match, actions, cb)->
      [_, name, x, y] = match
      actions.move name, parseInt(x, 10), parseInt(y, 10), cb
  pause:
    match: /pause\s+(\d+)/
    handle: (match, actions, cb)->
      [_, time] = match
      actions.pause parseInt(time, 10), cb
  say:
    match: /say\s+(.+)/
    handle: (match, actions, cb)->
      [_, text] = match
      actions.say text, cb
  says:
    match: /(\w+)\s+says\s+(.*)/
    handle: (match, actions, cb)->
      [_, name, text] = match
      actions.says name, text, cb
  go:
    match: /^\s*$/
    handle: (match, actions, cb)->
      actions.go cb

exports.parse = parse
exports.grammer = grammer
