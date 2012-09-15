/* storyturtle v0.0.5 | http://github.com/kevinbeaty/storyturtle | License: MIT */
;(function(root) {
var storyturtle = {}
  , require = function(path){
      var mod = /(\w+)\.?.*$/.exec(path)[1]
      return storyturtle[mod]
}
storyturtle.runloop = (function(exports){
var deferred = null
  , lastTime = 0
  , raf =  root.requestAnimationFrame 
        || root.webkitRequestAnimationFrame
        || root.mozRequestAnimationFrame
        || root.msRequestAnimationFrame
        || root.oRequestAnimationFrame
        || function(cb, element) {
             // Based on https://gist.github.com/1579671
             var currTime = +new Date()
               , timeToCall = Math.max(0, 16 - (currTime - lastTime))
               , id = root.setTimeout(function(){cb(currTime + timeToCall)}, timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        }
  ;

exports.subscribe = subscribe
function subscribe(responder){
  return run().subscribe(responder)
}

exports.run = run 
function run(){
  if(!deferred){
    deferred = _r.deferred()
    loop() 
  }
  return deferred
}

exports.stop = stop
function stop(){
  deferred.complete()
  deferred = null
}


function loop(){
  if(deferred){
    raf(loop)
    deferred.next(+new Date)
  }
}
return exports; })({})
storyturtle.featuretype = (function(exports){
exports.FeatureType = FeatureType
function FeatureType(name, canvas){
  this.name = name
  this.canvas = canvas
}
var P = FeatureType.prototype
return exports; })({})
storyturtle.feature = (function(exports){
exports.Feature = Feature
function Feature(name, type){
  this.name = name
  this.type = type
  this.alive = true
}
var P = Feature.prototype

P.position = function(x, y){
  this.x = x
  this.y = y
  return this
}

P.size = function(width, height){
  this.width = width
  this.height = height
  return this
}
return exports; })({})
storyturtle.context = (function(exports){
var FeatureType = require('./featuretype').FeatureType
  , Feature = require('./feature').Feature
  , runloop = require('./runloop')
  , types = {}
  , features = {}
  , canvas, context

exports.setCanvas = setCanvas
function setCanvas(c){
  canvas = c
  context = canvas.getContext('2d')

  var sub = runloop.subscribe(function(){
    if(!context){
      sub.dispose()
    }

    context.clearRect(0, 0, canvas.width, canvas.height)
  })
}

exports.setSpeaker = setSpeaker
function setSpeaker(fun){
  exports.speak = fun
}

exports.addFeatureType = addFeatureType
function addFeatureType(name, canvas){
  var featureType = new FeatureType(name, canvas)
  types[name] = featureType
  return featureType
}

exports.feature = feature
function feature(name){
  return features[name]
}

exports.addFeature = addFeature
function addFeature(name, typeName){
  var type = types[typeName]
    , feature = new Feature(name, type)
    , sub = runloop.subscribe(function(){
        var img = feature.type.canvas
        context.drawImage(img,
          0, 0, img.width, img.height,
          feature.x, feature.y, feature.width, feature.height)
        if(!feature.alive){
          sub.dispose()
        }
      })
  features[name] = feature
  return feature
}

exports.removeFeature = removeFeature
function removeFeature(name){
  var feature = features[name]
  if(feature){
    feature.alive = false
    delete features[name]
  }
}
return exports; })({})
storyturtle.imageloader = (function(exports){
var loadImages = _r()
  .seq()
  .map(function(character){
    return {
        name: character[0]
      , src: character[1]
      , loadImage: function(){
          var self = this
            , defer = _r.deferred()
          self.image = document.createElement('img')
          self.image.onload = function(){
            defer.resolve(self)
          }
          self.image.src = self.src
          return defer.promise
        }
    }})
  .call('loadImage')
  .pick('name', 'image')

//exports.loadImages = loadImages.callback()
exports.loadImages = function(images){
  return loadImages.attach(images)
}
return exports; })({})
storyturtle.parser = (function(exports){
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
return exports; })({})
storyturtle.init = (function(exports){
var config = {
    images: {} // Maps image type to URL
  , imageDimension: 30 // min dimension of images (aspect ratio maintained)
  , animationDuration: 1000 // duration of move animations, in milliseconds
  }
, context = require('./context')
, parse = require('./parser').parse
, loadImages = require('./imageloader').loadImages
, el = function(id){return document.getElementById('storyturtle-'+id)}
, on = function(el, type, listener){el.addEventListener(type, listener)}
, display = function(el, type){el.style.display = type}
, hide = function(el){display(el, 'none')}
, show = function(el, type){display(el, type || 'block')}

exports.init = init
function init(options){
  _r(options)
    .defaults(config)
    .first()
    .then(
      function(conf){
        config = conf
        return loadImages(config.images)
          .then(null, null, addFeatureType)
      })
    .then(function(){
      initElements()
    })
}

function initElements(){
  var editor = el('story')
  , canvas = el('canvas')
  , speaker = el('speaker')
  , controls = el('controls')
  , play = el('play')
  , edit = el('edit')
  , storage = store(editor)
  , storedGame = storage.get()

  context.setCanvas(canvas)

  context.setSpeaker(function(text){
    var child = speaker.firstChild
    for(; child !== null; child = speaker.firstChild)
      speaker.removeChild(child)
    speaker.appendChild(document.createTextNode(text))
  })

  if(storedGame){
    // If we previously stored game, load it
    editor.value = storedGame
  }

  on(play, 'click', function(){
    show(canvas)
    hide(editor)
    show(edit)
    hide(controls)
    gameText = editor.value

    parse(gameText, config).then(function(){
      speaker.innerHTML = ''
      show(controls)
    })

    storage.set(gameText)

    return false
  })

  on(edit, 'click', function(){
    hide(canvas)
    hide(edit)
    show(editor)
    return false
  })
}

function addFeatureType(image){
  var img = image.image
    , name = image.name
    , canvas = document.createElement('canvas')
  canvas.width = img.width
  canvas.height = img.height
  context2d = canvas.getContext('2d')
  context2d.drawImage(img, 0, 0)
  context.addFeatureType(name, canvas)
}

function store(game){return {
    set: function(text){
      var name = game.getAttribute('data-story')
      if(name && localStorage)
        localStorage.setItem('storyturtle_'+name, text)
    }

  , get: function(){
      var name = game.getAttribute('data-story')
      return name && localStorage && localStorage.getItem('storyturtle_'+name)
    }
}}
return exports; })({})
root.storyturtle = require('./init').init;}(this))
