PROJECT:=storyturtle
VERSION:=0.0.5
HOMEPAGE:=http://github.com/kevinbeaty/storyturtle

JS_MODULES:=runloop featuretype feature context\
	imageloader parser init2 init

STORIES:=$(wildcard stories/*.txt)

.PHONY: all clean js test serve stories
all: js stories

clean:
	rm -rf build

serve:
	mvw

test: | node_modules
	npm test

node_modules:
	npm install

%.min.js: %.js | node_modules
	node_modules/uglify-js/bin/uglifyjs $< > $@

%.gz: %
	gzip -c9 $^ > $@

# JavaScript
JS_TARGET?=theme/public/js/storyturtle/$(PROJECT)-$(VERSION).js
js: $(JS_TARGET) $(JS_TARGET:.js=.min.js) $(JS_TARGET:.js=.min.js.gz)

$(JS_TARGET): build/src/combined.js
	echo "$$JS_HEADER" > $@
	cat $< >> $@
	echo $(JS_FOOTER) >> $@

build/src:
	mkdir -p build/src

build/src/combined.js: $(JS_MODULES:%=build/src/%.js) | build/src
	cat $^ > $@

build/src/%.js: src/%.js | build/src
	echo $(JS_MODULE_HEADER) > $@
	cat $< >> $@
	echo $(JS_MODULE_FOOTER) >> $@

define JS_HEADER
/* $(PROJECT) v$(VERSION) | $(HOMEPAGE) | License: MIT */
;(function(root) {
var $(PROJECT) = {}
  , require = function(path){
      var mod = /(\w+)\.?.*$$/.exec(path)[1]
      return $(PROJECT)[mod]
}
endef
export JS_HEADER

JS_MODULE_HEADER="$(PROJECT).$(notdir $(basename $@)) = (function(exports){"
JS_MODULE_FOOTER="return exports; })({})"

JS_FOOTER="}(this))"

# Stories
stories: $(addprefix build/stories/, $(notdir $(STORIES:.txt=.md))) | build/stories

build/stories:
	mkdir -p build/stories

build/stories/%.md: stories/%.txt | build/stories
	echo "$$STORY_HEADER" > $@
	echo $(STORY_MODULE_HEADER) >> $@
	cat $< >> $@
	echo $(STORY_MODULE_FOOTER) >> $@
	echo $(STORY_FOOTER) >> $@

define STORY_HEADER
theme:storyturtle

endef
export STORY_HEADER

STORY_MODULE_HEADER='<div class="story" data-story="$(notdir $(basename $@))">'
STORY_MODULE_FOOTER='</div>'

STORY_FOOTER=
