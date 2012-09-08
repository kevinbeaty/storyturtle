context = require('./context')
runloop = require('./runloop')

class Actions
  constructor: (@config, @speaker)->
    @moveQueue = []

  create: (name, type, x, y)->
    console.log('create '+name+' '+type+' '+x+' '+y)
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

    return true


  die: (name)->
    console.log('die '+name)
    context.removeFeature(name)
    return true

  move: (name, x, y)->
    console.log('move '+name+' '+x+' '+y)
    feature = context.feature(name)
    feature and @moveQueue.push
      feature: feature 
      x1: feature.x
      x2: x
      y1: feature.y
      y2: y
    return true

  go: ()->
    console.log('go')
    move = @moveQueue
    @moveQueue = []
    if move.length
      return @animate(move)
    else
      return true 

  animate: (move)->
    console.log('begin animate '+move)
    defer = _r.deferred()
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
        console.log('done animate '+move)
        defer.resolve(true)
        return false 
    return defer

  pause: (time)->
    console.log('pause '+time)
    return _r(true).delay(time * 10)

  say:(text)->
    console.log('speak '+text)
    @speaker.text text
    return true

  says: (name, text)->
    console.log(name + ' says '+text)
    @speaker.text "#{name} says, \"#{text}\""
    return true

exports.Actions = Actions
