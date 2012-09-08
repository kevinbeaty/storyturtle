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
