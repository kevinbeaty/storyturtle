/* storyturtle v0.0.5 | http://github.com/kevinbeaty/storyturtle | License: MIT */
;(function(root) {
var storyturtle = {}
  , require = function(path){
      var mod = /(\w+)\.?.*$/.exec(path)[1]
      return storyturtle[mod]
}
storyturtle.config = (function(exports){
var config;

config = {
  images: {},
  board: {
    width: 300,
    height: 300
  },
  editor: {
    rows: 15,
    cols: 30
  },
  controls: {
    width: 300,
    height: 25
  },
  animationDuration: 1000
};

exports.config = config;
return exports; })({})
storyturtle.runloop = (function(exports){
var running = false
  , responders = []
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

exports.run = run 
function run(){
  if(!running){
    running = true
    loop() 
  }
}

exports.stop = stop
function stop(){
  running = false
}

exports.addResponder = addResponder
function addResponder(responder){
  responders.push(responder)
  if(!running) run()
}

function loop(){
  if(running){
    raf(loop)
    respond()
  }
}

function respond(){
  var responder
    , i = 0
    , len = responders.length
    , finished = false

  var curTime = +new Date()
  for(; i < len; ++i){
    try {
      finished = !responders[i](curTime)
    } catch(e){
      finished = true
    }

    if(finished){
      responders.splice(i, 1)
      len--
    }
  }

  if(len <= 0){
    stop()
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

  runloop.addResponder(function(){
    if(!context){
      return false
    } 

    context.clearRect(0, 0, canvas.width, canvas.height)
    return true
  })
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
  features[name] = feature

  runloop.addResponder(function(){
    var img = feature.type.canvas
    context.drawImage(img, 
      0, 0, img.width, img.height, 
      feature.x, feature.y, feature.width, feature.height)
    return feature.alive
  })
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
exports.loadImages = loadImages
function loadImages(sources, cb){
  var images = {}
    , src, img
    , count=0
    ;

  for(src in sources){
    count++
  }

  countdown = function(){
    if(--count <= 0) cb(images)
  }

  for(src in sources){
    img = new Image()
    images[src] = img
    img.onload = countdown 
    img.src = sources[src]
  }
}
return exports; })({})
storyturtle.actions = (function(exports){
var Actions, context, runloop;

context = require('./context');

runloop = require('./runloop');

Actions = (function() {

  function Actions(config, speaker) {
    this.config = config;
    this.speaker = speaker;
    this.moveQueue = [];
  }

  Actions.prototype.create = function(name, type, x, y) {
    var dim, feature, height, img, scale, width, _ref;
    console.log('create ' + name + ' ' + type + ' ' + x + ' ' + y);
    context.removeFeature(name);
    feature = context.addFeature(name, type);
    feature.position(x, y);
    dim = this.config.board.width / 10;
    if (feature != null ? (_ref = feature.type) != null ? _ref.canvas : void 0 : void 0) {
      img = feature.type.canvas;
      width = img.width || dim;
      height = img.height || dim;
      scale = dim / height;
      width *= scale;
      height *= scale;
    } else {
      height = dim;
      width = dim;
    }
    feature.size(width, height);
    return true;
  };

  Actions.prototype.die = function(name) {
    console.log('die ' + name);
    context.removeFeature(name);
    return true;
  };

  Actions.prototype.move = function(name, x, y) {
    var feature;
    console.log('move ' + name + ' ' + x + ' ' + y);
    feature = context.feature(name);
    feature && this.moveQueue.push({
      feature: feature,
      x1: feature.x,
      x2: x,
      y1: feature.y,
      y2: y
    });
    return true;
  };

  Actions.prototype.go = function() {
    var move;
    console.log('go');
    move = this.moveQueue;
    this.moveQueue = [];
    if (move.length) {
      return this.animate(move);
    } else {
      return true;
    }
  };

  Actions.prototype.animate = function(move) {
    var defer, duration, start;
    console.log('begin animate ' + move);
    defer = _r.deferred();
    start = +(new Date);
    duration = this.config.animationDuration || 1000;
    runloop.addResponder(function(now) {
      var f, percent, _i, _j, _len, _len2;
      percent = (now - start) / duration;
      if (percent < 1) {
        for (_i = 0, _len = move.length; _i < _len; _i++) {
          f = move[_i];
          f.feature.position(f.x1 + (f.x2 - f.x1) * percent, f.y1 + (f.y2 - f.y1) * percent);
        }
        return true;
      } else {
        for (_j = 0, _len2 = move.length; _j < _len2; _j++) {
          f = move[_j];
          f.feature.position(f.x2, f.y2);
        }
        console.log('done animate ' + move);
        defer.resolve(true);
        return false;
      }
    });
    return defer;
  };

  Actions.prototype.pause = function(time) {
    console.log('pause ' + time);
    return _r(true).delay(time * 10);
  };

  Actions.prototype.say = function(text) {
    console.log('speak ' + text);
    this.speaker.text(text);
    return true;
  };

  Actions.prototype.says = function(name, text) {
    console.log(name + ' says ' + text);
    this.speaker.text("" + name + " says, \"" + text + "\"");
    return true;
  };

  return Actions;

})();

exports.Actions = Actions;
return exports; })({})
storyturtle.parser = (function(exports){
var actions // TODO how should we handle actions?
var grammer = _r()
  .map([
      _r() // create
        .map(/(\w+)\s+is\s+an?\s+(\w+)\s+at\s+(\d+)\s+(\d+)/)
        .filter()
        .map(function(match){
          return actions.create(
              match[1]
            , match[2]
            , parseInt(match[3], 10)
            , parseInt(match[4], 10))})
    , _r() // die
        .map(/(\w+)\s+dies/)
        .filter()
        .map(function(match){
          return actions.die(match[1])
        })
    , _r() // move
        .map(/(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/)
        .filter()
        .map(function(match){
          return actions.move(
              match[1]
            , parseInt(match[2], 10)
            , parseInt(match[3], 10))
        })
    , _r() // pause
        .map(/pause\s+(\d+)/)
        .filter()
        .map(function(match){
          return actions.pause(parseInt(match[1], 10))
        })
    , _r() // say
        .map(/say\s+(.+)/)
        .filter()
        .map(function(match){
          return actions.say(match[1])
        })
    , _r() // says
        .map(/(\w+)\s+says\s+(.*)/)
        .filter()
        .map(function(match){
          return actions.says(match[1], match[2])
        })
    , _r() // go
        .filter(/^\s*$/)
        .map(function(){
          return actions.go()
        })
  ])

exports.parse = parse
function parse(text, acts){
  actions = acts
  var lines = text.split('\n')
  lines.push('\n') // always "go" at end
  var promise
  lines.forEach(function(line){
    if(promise) {
      promise = promise.then(_r(line).map(grammer))
    } else {
      promise = _r(line).map(grammer)
    }
  })
  return promise
  //return _r(lines).mapSeries(grammer).then(function(res){console.log('Done '+res); cb()})
}

exports.parse = parse
exports.grammer = grammer
return exports; })({})
storyturtle.init2 = (function(exports){
var loadImages = require('./imageloader').loadImages
  , runloop = require('./runloop')
  , gameContext = require('./context')

exports.init = init
function init(game, config){
  var canvas = document.createElement('canvas') 
    , context = canvas.getContext('2d')

  canvas.width = config.board.width
  canvas.height = config.board.height
  game.appendChild(canvas)

  loadImages(config.images, function(images){
      addFeatureTypes(images)
      gameContext.setCanvas(canvas)
  })
}

function addFeatureTypes(images){
  var name, img, canvas, context
  for(name in images){
    img = images[name]
    canvas = document.createElement('canvas')
    canvas.width = img.width
    canvas.height = img.height
    context = canvas.getContext('2d')
    context.drawImage(img, 0, 0)
    gameContext.addFeatureType(name, canvas)
  }
}
return exports; })({})
storyturtle.init = (function(exports){
var $, Actions, config, init, parse, store;

config = require('./config').config;

parse = require('./parser').parse;

Actions = require('./actions').Actions;

$ = jQuery;

$.fn.storyturtle = function(options) {
  config = $.extend(true, config, options);
  return this.each(function() {
    return init($(this));
  });
};

init = function(game) {
  var controls, edit, editor, play, speaker, storage, storedGame, _ref;
  game.hide().width(Math.max(config.board.width, config.controls.width)).height(config.board.height + config.controls.height);
  editor = $("<textarea>", {
    rows: config.editor.rows,
    cols: config.editor.cols
  }).hide().val(game.text()).appendTo(game.text(""));
  speaker = $("<div>").width(config.controls.width).height(config.controls.height).appendTo(game);
  play = $("<a>", {
    href: '#'
  }).text("Play!").css({
    float: "left"
  });
  edit = $("<a>", {
    href: '#'
  }).text("Edit").css({
    float: "right"
  });
  controls = $("<div>").width(config.controls.width).height(config.controls.height).append(play, edit).appendTo(game);
  if ((_ref = require('./init2')) != null) _ref.init($(game).get(0), config);
  storage = store(game);
  if (storedGame = storage.get()) editor.val(storedGame);
  play.click(function() {
    var actions, gameText;
    editor.hide();
    edit.show();
    controls.hide();
    gameText = editor.val();
    actions = new Actions(config, speaker);
    parse(gameText, actions).then(function() {
      speaker.text("");
      return controls.show();
    });
    storage.set(gameText);
    return false;
  });
  edit.click(function() {
    edit.hide();
    editor.show();
    return false;
  });
  return game.show();
};

store = function(game) {
  return {
    set: function(text) {
      var name;
      name = game.data("story");
      if (name) {
        return typeof localStorage !== "undefined" && localStorage !== null ? localStorage.setItem("storyturtle_" + name, text) : void 0;
      }
    },
    get: function() {
      var name;
      name = game.data("story");
      return name && (typeof localStorage !== "undefined" && localStorage !== null ? localStorage.getItem("storyturtle_" + name) : void 0);
    }
  };
};
return exports; })({})
}(this))
