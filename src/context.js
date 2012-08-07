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
