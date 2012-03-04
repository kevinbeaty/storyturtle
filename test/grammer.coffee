should = require 'should'
{grammer} = require '../src/parser'

{ create
  die
  move
  pause
  say
  says
  go
} = grammer

matchesOnly = (line, topic) ->
  line.should.match topic.match

  matchOther = null
  matchTopic = null
  for own key, check of grammer
    match = check.match.exec line
    if match
      if check.match is topic.match
        matchTopic = match
      else
        matchOther = match
  should.exist matchTopic
  should.not.exist matchOther

  line.trim().should.eql matchTopic[0].trim()
  matchTopic[1...]

matchesNone = (line) ->
  for own key, check of grammer
    match = check.match.exec line
    should.not.exist match

describe 'Grammer Test', ->
  describe 'create', ->
    it 'exists', ->
      should.exist create
    it 'has match that is a RegExp', ->
      create.match.should.be.an.instanceof RegExp
    it 'has handle that is a function', ->
      create.handle.should.be.a 'function'
    it 'matches "fred is a dog at 10 15"', ->
      line = "fred is a dog at 10 15"
      [name, type, x, y] = matchesOnly line, create
      name.should.eql "fred"
      type.should.eql "dog"
      x.should.eql "10"
      y.should.eql "15"
    it 'matches " hank   is a fish  at 30  40 "', ->
      line = " hank   is a fish  at 30  40 "
      [name, type, x, y] = matchesOnly line, create
      name.should.eql "hank"
      type.should.eql "fish"
      x.should.eql "30"
      y.should.eql "40"
    it 'matches "harry is an octopus at 100 300"', ->
      line = "harry is an octopus at 100 300"
      [name, type, x, y] = matchesOnly line, create
      name.should.eql "harry"
      type.should.eql "octopus"
      x.should.eql "100"
      y.should.eql "300"
    it 'does not match "megan is a cat at 10 ux"', ->
      line = "megan is a cat at 10 ux"
      matchesNone line
    it 'does not match "bob is a bug"', ->
      line = "bob is a bug"
      matchesNone line
  describe 'die', ->
    it 'exists', ->
      should.exist die
    it 'has match that is regexp', ->
      die.match.should.be.an.instanceof RegExp
    it 'has handle that is a function', ->
      die.handle.should.be.a 'function'
    it 'matches "ed dies"', ->
      line = "ed dies"
      [name] = matchesOnly line, die
      name.should.eql "ed"
    it 'matches " wanda  dies "', ->
      line = " wanda  dies "
      [name] = matchesOnly line, die
      name.should.eql "wanda"
    it 'does not match " willy die "', ->
      line = " willy die "
      matchesNone line
  describe 'move', ->
    it 'exists', ->
      should.exist move
    it 'has match that is regexp', ->
      move.match.should.be.an.instanceof RegExp
    it 'has handle that is a function', ->
      move.handle.should.be.a 'function'
    it 'matches "sally moves to 30 20"', ->
      line = "sally moves to 30 20"
      [name, x, y] = matchesOnly line, move
      name.should.eql "sally"
      x.should.eql "30"
      y.should.eql "20"
    it 'matches "  fran    moves to 33   78  "', ->
      line = "  fran    moves to 33   78  "
      [name, x, y] = matchesOnly line, move
      name.should.eql "fran"
      x.should.eql "33"
      y.should.eql "78"
    it 'does not match "luanne moves to 3z 10"', ->
      line = "luanne moves to 3z 10"
      matchesNone line
    it 'does not match " hank moves "', ->
      line = " hank moves "
      matchesNone line
  describe 'pause', ->
    it 'exists', ->
      should.exist pause
    it 'has match that is regexp', ->
      pause.match.should.be.an.instanceof RegExp
    it 'has handle that is a function', ->
      pause.handle.should.be.a 'function'
    it 'matches "pause 20"', ->
      line = "pause 20"
      [time] = matchesOnly line, pause
      time.should.eql "20"
    it 'matches " pause  30 "', ->
      line = " pause  30 "
      [time] = matchesOnly line, pause
      time.should.eql "30"
    it 'does not match "pause f10"', ->
      matchesNone "pause f10"
  describe 'say', ->
    it 'exists', ->
      should.exist say
    it 'has match that is regexp', ->
      say.match.should.be.an.instanceof RegExp
    it 'has handle that is a function', ->
      say.handle.should.be.a 'function'
    it 'matches "say hello world"', ->
      line = "say hello world"
      [text] = matchesOnly line, say
      text.should.eql "hello world"
    it 'matches " say   this is awesome "', ->
      line = " say   this is awesome "
      [text] = matchesOnly line, say
      text.should.eql "this is awesome "
    it 'does not match "say"', ->
      matchesNone "say"
  describe 'says', ->
    it 'exists', ->
      should.exist says
    it 'has match that is regexp', ->
      says.match.should.be.an.instanceof RegExp
    it 'has handle that is a function', ->
      says.handle.should.be.a 'function'
    it 'matches "pablo says awesome possum"', ->
      line = "pablo says awesome possum"
      [name, text] = matchesOnly line, says
      name.should.eql "pablo"
      text.should.eql "awesome possum"
    it 'matches "  frank   says   cool beans"', ->
      line = "  frank   says   cool beans"
      [name, text] = matchesOnly line, says
      name.should.eql "frank"
      text.should.eql "cool beans"
    it 'does not match "hope says"', ->
      matchesNone "hope says"
  describe 'go', ->
    it 'exists', ->
      should.exist go
    it 'has match that is regexp', ->
      go.match.should.be.an.instanceof RegExp
    it 'has handle that is a function', ->
      go.handle.should.be.a 'function'
    it 'matches ""', ->
      matchesOnly "", go
    it 'matches "  "', ->
      matchesOnly "  ", go
    it 'matches "\\t \\t"', ->
      matchesOnly "\t \t", go
    it 'does not match "go"', ->
      matchesNone "go"
