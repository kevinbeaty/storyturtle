exports.feature = (type, config, cb) ->
  if type of config.images
    img = new Image()
    img.src = config.images[type]
    $(img).load ->
      dim = config.board.width / 10
      width = img.width or dim
      height = img.height or dim
      scale = dim/height
      width *= scale
      height *= scale
      feature = $("<img>", src:img.src)
      feature.css
        width:width
        height:height
      cb feature
