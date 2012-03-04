class Actions
  constructor: (@config, @board, @speaker, @offset={top:0, left:0})->
    @features = {}
    @moveQueue = []

  create: (name, type, x, y, cb)->
    x += @offset.left
    y += @offset.top

    feature = @features[name]
    feature.remove() if feature
    @feature type, (feature) =>
      feature.css
        position: 'absolute'
        left:x
        top:y
      feature.appendTo @board
      @features[name] = feature
      cb()

  die: (name, cb)->
    feature = @features[name]
    feature.remove() if feature
    cb()

  move: (name, x, y, cb)->
    x += @offset.left
    y += @offset.top

    feature = @features[name]
    feature and @moveQueue.push
      feature: feature
      attrs:
        left:x
        top:y
    cb()

  go: (cb)->
    count = @moveQueue.length
    countdown = ->
      cb() unless count--

    toMove = @moveQueue.pop()

    while toMove
      toMove.feature.animate(
        toMove.attrs
        1000
        'linear'
        countdown)
      toMove = @moveQueue.pop()

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
