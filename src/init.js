var config = {
    images: {} // Maps image type to URL
  , board: {width: 300, height: 300}
  , editor: {rows: 15, cols: 30}
  , controls: {width: 300, height: 25}
  , animationDuration: 1000
  }
, context = require('./context')
, parse = require('./parser').parse
, store = function(game){return {
      set: function(text){
        var name = game.data('story')
        if(name && localStorage)
          localStorage.setItem('storyturtle_'+name, text)
      }

    , get: function(){
        var name = game.data('story')
        return name && localStorage && localStorage.getItem('storyturtle_'+name)
      }
  }}

, $ = jQuery
, init = function(game){
  game.hide()
    .width(Math.max(config.board.width, config.controls.width))
    .height(config.board.height+config.controls.height)

  var editor = $('<textarea>',
      { rows: config.editor.rows
      , cols: config.editor.cols})
    .hide()
    .val(game.text())
    .appendTo(game.text(''))

  , speaker = $('<div>')
    .width(config.controls.width)
    .height(config.controls.height)
    .appendTo(game)

  , play = $('<a>', {href:'#'})
    .text('Play!')
    .css({'float': 'left'})

  , edit = $('<a>', {href: '#'})
    .text('Edit')
    .css({'float': 'right'})

  , controls = $('<div>')
    .width(config.controls.width)
    .height(config.controls.height)
    .append(play, edit)
    .appendTo(game)

  , storage = store(game)
  , storedGame = storage.get()

  require('./init2').init($(game).get(0), config)

  context.setSpeaker(function(text){
    speaker.text(text)
  })

  if(storedGame){
    // If we previously stored game, load it
    editor.val(storedGame)
  }

  play.click(function(){
    editor.hide()
    edit.show()
    controls.hide()
    gameText = editor.val()

    parse(gameText, config).then(function(){
      speaker.text('')
      controls.show()
    })

    storage.set(gameText)

    return false
  })

  edit.click(function(){
    edit.hide()
    editor.show()
    return false
  })

  game.show()
}

$.fn.storyturtle = function(options){
  config = $.extend(true, config, options)
  this.each(function(){
    init($(this))
  })
}
