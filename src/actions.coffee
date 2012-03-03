feature = (type, context, cb) ->
  {config} = context
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
      f = $("<img>", src:img.src)
      f.css
        width:width
        height:height
      cb f

create = (cb, context, name, type, x, y) ->
  {features, board} = context

  f = features[name]
  f.remove() if f
  feature type, context, (f) ->
    f.css
      position: 'absolute'
      left:x
      top:y
    f.appendTo board
    features[name] = f
    cb()

die = (cb, context, name) ->
  {features} = context
  f = features[name]
  f.remove() if f
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

pause = (cb, context, time)->
  setTimeout cb, time

say = (cb, context, text)->
  {speaker} = context
  speaker.text text
  cb()

says = (cb, context, name, text)->
  {speaker} = context
  speaker.text "#{name} says, \"#{text}\""
  cb()

exports.create = create
exports.die = die
exports.move = move
exports.go = go
exports.pause = pause
exports.say = say
exports.says = says
