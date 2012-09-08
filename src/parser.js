var actions // TODO how should we handle actions?
var grammer = _r()
  .map([
      _r() // create
        .map(/(\w+)\s+is\s+an?\s+(\w+)\s+at\s+(\d+)\s+(\d+)/)
        .filter()
        .map(function(match){
          return actions.create(
              match[1]
            , match[2]
            , parseInt(match[3], 10)
            , parseInt(match[4], 10))})
    , _r() // die
        .map(/(\w+)\s+dies/)
        .filter()
        .map(function(match){
          return actions.die(match[1])
        })
    , _r() // move
        .map(/(\w+)\s+moves\s+to\s+(\d+)\s+(\d+)/)
        .filter()
        .map(function(match){
          return actions.move(
              match[1]
            , parseInt(match[2], 10)
            , parseInt(match[3], 10))
        })
    , _r() // pause
        .map(/pause\s+(\d+)/)
        .filter()
        .map(function(match){
          return actions.pause(parseInt(match[1], 10))
        })
    , _r() // say
        .map(/say\s+(.+)/)
        .filter()
        .map(function(match){
          return actions.say(match[1])
        })
    , _r() // says
        .map(/(\w+)\s+says\s+(.*)/)
        .filter()
        .map(function(match){
          return actions.says(match[1], match[2])
        })
    , _r() // go
        .filter(/^\s*$/)
        .map(function(){
          return actions.go()
        })
  ])

exports.parse = parse
function parse(text, acts){
  actions = acts
  var lines = text.split('\n')
  lines.push('\n') // always "go" at end
  var promise
  lines.forEach(function(line){
    if(promise) {
      promise = promise.then(_r(line).map(grammer))
    } else {
      promise = _r(line).map(grammer)
    }
  })
  return promise
  //return _r(lines).mapSeries(grammer).then(function(res){console.log('Done '+res); cb()})
}

exports.parse = parse
exports.grammer = grammer
