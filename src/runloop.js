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
