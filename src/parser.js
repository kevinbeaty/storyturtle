var context = require('./context')
  , runloop = require('./runloop')
  , config = {}
  , moveQueue = []
  , create = function(name, type, x, y){
      context.removeFeature(name)
      var feature = context.addFeature(name, type)
        , img = feature.type.canvas
        , dim = config.imageDimension || 30
        , width = img.width || dim
        , height = img.height || dim
        , scale = dim/height

      width *= scale
      height *= scale

      feature.position(x, y)
      feature.size(width, height)
    }
  , move = function(name, x, y){
      var feature = context.feature(name)
      feature && moveQueue.push({
          feature: feature
        , x1: feature.x
        , x2: x
        , y1: feature.y
        , y2: y
      })
    }
  , go = function(){
      var move = moveQueue
      moveQueue = []
      if(move.length){
        return animate(move)
      }
    }
  , animate = function(move){
      var defer = _r.deferred()
        , start = +new Date
        , duration = config.animationDuration || 1000
        , sub = runloop.subscribe(function(now){
            percent = (now - start)/duration
            if(percent < 1){
              _r(move).each(function(f){
                f.feature.position(
                    f.x1 + (f.x2 - f.x1)*percent
                  , f.y1 + (f.y2 - f.y1)*percent)
              })
            } else {
              _r(move).each(function(f){
                f.feature.position(f.x2, f.y2)
              })
              defer.resolve(true)
              sub.dispose()
            }
          })
        return defer
      }

  , grammer = _r().map([
      _r() // create
        .map(/(\w+)\s+is\s+an?\s+(\w+)\s+at\s+(\d+)\s+(\d+)/)
        .filter()
        .map(function(match){
          return create(
              match[1]
            , match[2]
            , parseInt(match[3], 10)
            , parseInt(match[4], 10))})
    , _r() // die
        .map(/(\w+)\s+dies/)
        .filter()
        .map(function(match){
          return context.removeFeature(match[1])
        })
    , _r() // move
        .map(/(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/)
        .filter()
        .map(function(match){
          return move(
              match[1]
            , parseInt(match[2], 10)
            , parseInt(match[3], 10))
        })
    , _r() // pause
        .map(/pause\s+(\d+)/)
        .filter()
        .map(function(match){
          return _r(true).delay(parseInt(match[1], 10) * 10)
        })
    , _r() // say
        .map(/say\s+(.+)/)
        .filter()
        .map(function(match){
          return context.speak(match[1])
        })
    , _r() // says
        .map(/(\w+)\s+says\s+(.*)/)
        .filter()
        .map(function(match){
          return context.speak(match[1]+' says, "'+match[2]+ '"')
        })
    , _r() // go
        .filter(/^\s*$/)
        .map(go)
  ])

function parse(text, conf){
  config = conf || config
  moveQueue = []

  var lines = text.split('\n')
  lines.push('\n') // always "go" at end
  var promise
  _r(lines).each(function(line){
    if(promise) {
      promise = promise.then(_r(line).map(grammer))
    } else {
      promise = _r(line).map(grammer)
    }
  })
  return promise
  //return _r(lines).mapSeries(grammer)
}

exports.parse = parse
exports.grammer = grammer
