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
