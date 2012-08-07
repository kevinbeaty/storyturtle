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
