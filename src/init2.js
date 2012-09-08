var loadImages = require('./imageloader').loadImages
  , gameContext = require('./context')

exports.init = init
function init(game, config){
  var canvas = document.createElement('canvas') 
    , context = canvas.getContext('2d')

  canvas.width = config.board.width
  canvas.height = config.board.height
  game.appendChild(canvas)
  gameContext.setCanvas(canvas)

  loadImages(config.images).subscribe(addFeatureType)
}

function addFeatureType(image){
  var img = image.image
    , name = image.name
    , canvas = document.createElement('canvas')
  canvas.width = img.width
  canvas.height = img.height
  context = canvas.getContext('2d')
  context.drawImage(img, 0, 0)
  gameContext.addFeatureType(name, canvas)
}
