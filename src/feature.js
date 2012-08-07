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
