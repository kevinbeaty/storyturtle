{config} = require '../../src/config'
{Actions} = require '../../src/actions'

config.animationDuration = 1

class MockSpeaker
  constructor: ()->
    @_text = ""

  text: (text)->
    @_text = text

class MockActions extends Actions
  constructor: ()->
    super config, new MockSpeaker

exports.MockActions = MockActions
