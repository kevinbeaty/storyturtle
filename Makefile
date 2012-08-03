PROJECT:=storyturtle
VERSION:=0.0.5
HOMEPAGE:=http://simplectic.com/story_turtle

JS_MODULES:=config actions parser init

.PHONY: clean js test

all: js

clean:
	rm -rf build

test: | node_modules
	npm test

node_modules:
	npm install

%.js: %.coffee | node_modules
	node_modules/coffee-script/bin/coffee -cb $< > $@

%.min.js: %.js | node_modules
	node_modules/uglify-js/bin/uglifyjs $< > $@

%.gz: %
	gzip -c9 $^ > $@

# JavaScript
JS_TARGET?=build/$(PROJECT)-$(VERSION).js
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

