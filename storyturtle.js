/* storyturtle.js
 * License MIT
 * http://simplectic.com/story_turtle
 */
$(function() {
    var game = $("#game").hide(),
        editor = $("<textarea>", { rows: 15, cols: 30 }).
            hide().val(game.text()).appendTo(game.text("")),
        board = $("<div>").width(300).height(300).appendTo(game),
        speaker = $("<div>").width(350).appendTo(game),
        play = $("<a>", { href: '#' }).text("Play!").css({ float: "left" }),
        edit = $("<a>", { href: '#' }).text("Edit").css({ float: "right" }),
        controls = $("<div>").width(300).append(play, edit).appendTo(game),

        features = {},
        moveQueue = [],
        offset = {top: 0, left:0},

        create = function(cb, name, type, x, y) {
            var feature = features[name];
            if (feature) { 
                feature.remove(); 
            }
            feature = $("<img>", {src: "images/"+type+".png"});
            feature.css({position: 'absolute', left: x, top: y, width: 30, height: 30});
            feature.appendTo(board);
            features[name] = feature;
            cb();
        },

        move = function(cb, name, x, y) {
            var feature = features[name];
            if (feature) {
                moveQueue.push({
                    feature: feature,
                    attrs: { left: x, top: y }});
            }
            cb();
        },
        
        go = function(cb) {
            var count = moveQueue.length,
                countdown = function() {
                    if (count-- <= 0) {
                        cb();
                    }
                },
                toMove = moveQueue.pop(); 

            while (toMove) {
                toMove.feature.animate(toMove.attrs, 1000, 'linear', countdown);
                toMove = moveQueue.pop();
            }

            countdown();
        },

        grammer = {

            create: {
                match: /(\w*) is an? (\w*) at (\w*) (\w*)/,
                handle: function(match, cb) {
                    create(cb, 
                        match[1],
                        match[2],
                        parseInt(match[3], 10) + offset.left,
                        parseInt(match[4], 10) + offset.top);
                }
            },

            die: {
                match: /(\w*) dies/,
                handle: function(match, cb) {
                    var feature = features[match[1]];
                    if(feature){
                        feature.remove();
                    }
                    cb();
                }
            },
            
            move: {
                match: /(\w*) moves to (\w*) (\w*)/,
                handle: function(match, cb) {
                    move(cb, 
                        match[1], 
                        parseInt(match[2], 10) + offset.left,
                        parseInt(match[3], 10) + offset.top);
                }
            },

            pause: {
                match: /pause (\w*)/,
                handle: function(match, cb) {
                    setTimeout(cb,
                        parseInt(match[1], 10) * 10);
                }
            },

            say: {
                match: /say (.*)/,
                handle: function(match, cb) {
                    speaker.text(match[1]);
                    cb();
                }
            },

            says: {
                match: /(\w*) says (.*)/,
                handle: function(match, cb) {
                    speaker.text(match[1] + " says, \"" + match[2] + "\"");
                    cb();
                }
            },

            go: {
                match: /^(\s*)$/,
                handle: function(match, cb) {
                    go(cb);
                }
            }
        },


        parse = function(text, cb) {
            var steps = [],
                parseLine = function(i, line) {
                    var match;
                    $.each(grammer, function(key, check) {
                        match = check.match.exec(line);
                        if (match) {
                            steps[steps.length] = { check: check, match: match };
                        }
                    });
                },
                idx = 0, 
                next;

            next = function() {
                var step = steps[idx++];
                if (step) {
                    step.check.handle(step.match, next);
                } else {
                    go(cb);
                } 
            };

            features = {};
            moveQueue = [];
            board.html("");

            $.each(text.split('\n'), parseLine);
            next();
        };

    play.click(function() {
        board.show();
        editor.hide();
        edit.show();
        controls.hide();
        gameText = editor.val();
        offset = $(board).offset();

        parse(gameText, function() {
            speaker.text("");
            controls.show();
        });
        return false; 
    });

    edit.click(function() {
        board.hide();
        edit.hide();
        editor.show();
        return false;
    });

    game.show();
});
