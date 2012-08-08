context = require('./context')
runloop = require('./runloop')

class Actions
  constructor: (@config, @speaker)->
    @moveQueue = []

  create: (name, type, x, y, cb)->
    context.removeFeature(name)

    feature = context.addFeature(name, type)
    feature.position(x, y)
    dim = @config.board.width / 10

    if feature?.type?.canvas
      img = feature.type.canvas
      width = img.width or dim
      height = img.height or dim
      scale = dim/height
      width *= scale
      height *= scale
    else
      height = dim
      width = dim

    feature.size(width, height)

    cb()

  die: (name, cb)->
    context.removeFeature(name)
    cb()

  move: (name, x, y, cb)->
    feature = context.feature(name)
    feature and @moveQueue.push
      feature: feature 
      x1: feature.x
      x2: x
      y1: feature.y
      y2: y
    cb()

  go: (cb)->
    move = @moveQueue
    @moveQueue = []
    if move.length
      @animate(move, cb)
    else
      cb()

  animate: (move, cb)->
    start = +new Date
    duration = @config.animationDuration or 1000
    runloop.addResponder (now)->
      percent = (now - start)/duration
      if percent < 1
        for f in move 
          f.feature.position(
            f.x1 + (f.x2 - f.x1)*percent
            f.y1 + (f.y2 - f.y1)*percent
          )
        return true 
      else
        for f in move 
          f.feature.position(f.x2, f.y2)
        cb()
        return false 

  pause: (time, cb)->
    setTimeout cb, time * 10

  say:(text, cb)->
    @speaker.text text
    cb()

  says: (name, text, cb)->
    @speaker.text "#{name} says, \"#{text}\""
    cb()

exports.Actions = Actions
