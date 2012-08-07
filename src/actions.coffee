context = require('./context')
runloop = require('./runloop')

class Actions
  constructor: (@config, @board, @speaker, @offset={top:0, left:0})->
    @features = {}
    @moveQueue = []

  create: (name, type, x, y, cb)->
    @_remove name

    @create2(name, type, x, y, cb)
    
    x += @offset.left
    y += @offset.top

    @feature type, (feature) =>
      feature.css
        position: 'absolute'
        left:x
        top:y
      feature.appendTo @board
      @features[name] = feature
      cb()

  create2: (name, type, x, y, cb)->
    feature = context.addFeature(name, type)
    feature.position(x, y)
    dim = @config.board.width / 10
    width = dim
    height = dim

    if feature.type?.canvas
      img = feature.type.canvas
      width = img.width or dim
      height = img.height or dim
      scale = dim/height
      width *= scale
      height *= scale
    feature.size(width, height)

  die: (name, cb)->
    @_remove name
    cb()

  _remove: (name)->
    context.removeFeature(name)
    feature = @features[name]
    if feature
      feature.remove()
      delete @features[name]

  move: (name, x, y, cb)->
    x += @offset.left
    y += @offset.top

    feature = @features[name]
    feature and @moveQueue.push
      feature: feature
      name: name
      attrs:
        left:x
        top:y
    cb()

  go: (cb)->
    count = @moveQueue.length
    countdown = ->
      cb() unless count--


    toMove = @moveQueue.pop()

    move2 = []
    while toMove
      toMove.feature.animate(
        toMove.attrs
        1000
        'linear'
        countdown)

      feature2 = context.feature(toMove.name)
      move2.push
        feature: feature2 
        x1: feature2.x
        x2: toMove.attrs.left - @offset.left
        y1: feature2.y
        y2: toMove.attrs.top - @offset.top

      toMove = @moveQueue.pop()

    start = +new Date
    runloop.addResponder (now)->
      percent = (now - start)/1000
      if percent < 1
        for f in move2 
          f.feature.position(
            f.x1 + (f.x2 - f.x1)*percent
            f.y1 + (f.y2 - f.y1)*percent
          )
        return true 
      else
        for f in move2 
          f.feature.position(f.x2, f.y2)
        return false 

    countdown()

  pause: (time, cb)->
    setTimeout cb, time * 10

  say:(text, cb)->
    @speaker.text text
    cb()

  says: (name, text, cb)->
    @speaker.text "#{name} says, \"#{text}\""
    cb()

  feature: (type, cb) ->
    config = @config
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

exports.Actions = Actions
