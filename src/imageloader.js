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
