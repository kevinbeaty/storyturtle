var config = {
    images: {} // Maps image type to URL
  , imageDimension: 30 // min dimension of images (aspect ratio maintained)
  , animationDuration: 1000 // duration of move animations, in milliseconds
  }
, context = require('./context')
, parse = require('./parser').parse
, loadImages = require('./imageloader').loadImages
, el = function(id){return document.getElementById('storyturtle-'+id)}
, on = function(el, type, listener){el.addEventListener(type, listener)}
, display = function(el, type){el.style.display = type}
, hide = function(el){display(el, 'none')}
, show = function(el, type){display(el, type || 'block')}

exports.init = init
function init(options){
  _r(options)
    .defaults(config)
    .first()
    .then(
      function(conf){
        config = conf
        return loadImages(config.images)
          .then(null, null, addFeatureType)
      })
    .then(function(){
      initElements()
    })
}

function initElements(){
  var editor = el('story')
  , canvas = el('canvas')
  , speaker = el('speaker')
  , controls = el('controls')
  , play = el('play')
  , edit = el('edit')
  , storage = store(editor)
  , storedGame = storage.get()

  context.setCanvas(canvas)

  context.setSpeaker(function(text){
    var child = speaker.firstChild
    for(; child !== null; child = speaker.firstChild)
      speaker.removeChild(child)
    speaker.appendChild(document.createTextNode(text))
  })

  if(storedGame){
    // If we previously stored game, load it
    editor.value = storedGame
  }

  on(play, 'click', function(){
    show(canvas)
    hide(editor)
    show(edit)
    hide(controls)
    gameText = editor.value

    parse(gameText, config).then(function(){
      speaker.innerHTML = ''
      show(controls)
    })

    storage.set(gameText)

    return false
  })

  on(edit, 'click', function(){
    hide(canvas)
    hide(edit)
    show(editor)
    return false
  })
}

function addFeatureType(image){
  var img = image.image
    , name = image.name
    , canvas = document.createElement('canvas')
  canvas.width = img.width
  canvas.height = img.height
  context2d = canvas.getContext('2d')
  context2d.drawImage(img, 0, 0)
  context.addFeatureType(name, canvas)
}

function store(game){return {
    set: function(text){
      var name = game.getAttribute('data-story')
      if(name && localStorage)
        localStorage.setItem('storyturtle_'+name, text)
    }

  , get: function(){
      var name = game.getAttribute('data-story')
      return name && localStorage && localStorage.getItem('storyturtle_'+name)
    }
}}
