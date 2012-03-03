vows = require 'vows'
assert = require 'assert'

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
  assert.match line, topic.match

  matchOther = null
  matchTopic = null
  for own key, check of grammer
    match = check.match.exec line
    if match
      if check.match is topic.match
        matchTopic = match
      else
        matchOther = match
  assert.isNotNull matchTopic
  assert.isNull matchOther

  assert.equal line.trim(), matchTopic[0].trim()
  matchTopic[1...]

matchesNone = (line) ->
  for own key, check of grammer
    match = check.match.exec line
    assert.isNull

vows
  .describe('Grammer Test')
  .addBatch
    'when matching create':
      topic: create
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
      'matches "fred is a dog at 10 15"': (topic)->
        line = "fred is a dog at 10 15"
        [name, type, x, y] = matchesOnly line, topic
        assert.equal name, "fred"
        assert.equal type, "dog"
        assert.equal x, "10"
        assert.equal y, "15"
      'matches " hank   is a fish  at 30  40 "': (topic)->
        line = " hank   is a fish  at 30  40 "
        [name, type, x, y] = matchesOnly line, topic
        assert.equal name, "hank"
        assert.equal type, "fish"
        assert.equal x, "30"
        assert.equal y, "40"
      'matches "harry is an octopus at 100 300"': (topic)->
        line = "harry is an octopus at 100 300"
        [name, type, x, y] = matchesOnly line, topic
        assert.equal name, "harry"
        assert.equal type, "octopus"
        assert.equal x, "100"
      'does not match "megan is a cat at 10 1x"': (topic)->
        line = "megan is a cat at 10 1x"
        matchesNone line
      'does not match "bob is a bug"': (topic)->
        line = "bob is a bug"
        matchesNone line
    'when matching die':
      topic: die
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
      'matches "ed dies"': (topic)->
        line = "ed dies"
        [name] = matchesOnly line, topic
        assert.equal name, "ed"
      'matches " wanda  dies "': (topic)->
        line = " wanda  dies "
        [name] = matchesOnly line, topic
        assert.equal name, "wanda"
      'does not match " willy die "': (topic)->
        line = " willy die "
        matchesNone line
    'when matching move':
      topic: move
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
      'matches "sally moves to 30 20"': (topic)->
        line = "sally moves to 30 20"
        [name, x, y] = matchesOnly line, topic
        assert.equal name, "sally"
        assert.equal x, "30"
        assert.equal y, "20"
      'matches "  fran    moves to 33   78  "': (topic)->
        line = "  fran    moves to 33   78  "
        [name, x, y] = matchesOnly line, topic
        assert.equal name, "fran"
        assert.equal x, "33"
        assert.equal y, "78"
      'does not match "luanne moves to 3z 10"': (topic)->
        line = "luanne moves to 3z 10"
        matchesNone line
      'does not match " hank moves "': (topic)->
        line = " hank moves "
        matchesNone line
    'when matching pause':
      topic: pause
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
      'matches "pause 20"': (topic)->
        line = "pause 20"
        [time] = matchesOnly line, topic
        assert.equal time, "20"
      'matches " pause  30 "': (topic)->
        line = " pause  30 "
        [time] = matchesOnly line, topic
        assert.equal time, "30"
      'does not match "pause f10"': (topic)->
        matchesNone "pause f10"
    'when matching say':
      topic: say
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
      'matches "say hello world"': (topic)->
        line = "say hello world"
        [text] = matchesOnly line, topic
        assert.equal "hello world", text
      'matches " say   this is awesome "': (topic)->
        line = " say   this is awesome "
        [text] = matchesOnly line, topic
        assert.equal "this is awesome ", text
      'does not match "say"': (topic)->
        matchesNone "say"
    'when matching says':
      topic: says
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
      'matches "pablo says awesome possum"': (topic)->
        line = "pablo says awesome possum"
        [name, text] = matchesOnly line, topic
        assert.equal name, "pablo"
        assert.equal text, "awesome possum"
      'matches "  frank   says   cool beans"': (topic)->
        line = "  frank   says   cool beans"
        [name, text] = matchesOnly line, topic
        assert.equal name, "frank"
        assert.equal text, "cool beans"
      'does not match "hope says"': (topic)->
        matchesNone "hope says"
    'when matching go':
      topic: go
      'it is defined': (topic)->
        assert.isObject topic
      'match is regexp': (topic)->
        assert.instanceOf topic.match, RegExp
      'handle is function': (topic)->
        assert.isFunction topic.handle
      'matches ""': (topic)->
        matchesOnly "", topic
      'matches "  "': (topic)->
        matchesOnly "  ", topic
      'matches "\\t \\t"': (topic)->
        matchesOnly "\t \t", topic
      'does not match "go"': (topic)->
        matchesNone "go"
  .export(module)
