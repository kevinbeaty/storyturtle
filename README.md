Story Turtle was a first introduction to programming for
my kids (aged 8 and 10).  The grammer, images, and example
stories were their own creation, as described below.

My initial goal was to create something very similar to 
[Khan CS](http://www.khanacademy.org/cs/), which is obviously more 
fully baked.

It has since become my "go to" script for exploring random technologies:
CoffeeScript, Makefiles for JavaScript, node.js, mocha, canvas, underarm, etc.

It is now admittedly over-engineered, but the point is exploration.

The kids have moved on to writing their own HTML/CSS.  They still love
"telling computers what to do".  It continues to be a thrill to experience
their neverending curiosity and sense of wonder.

## Writing a Story

The game board is a square. The top-left is `at 0 0`, and the bottom 
right is `at 300 300`.  You can add characters to the board by giving
them a name and telling them where to start. You can tell them to move
and tell them to die.  They can also say things. Each step is separated
by blank lines.

Example:

    say turtle diner

    bob is a shark at 123 134
    pause 100
     
    silly is a turtle at 56 123
    pause 200

    bob says i'm hungry 
    pause 300

    silly moves to 123 134

    bob dies

    silly says bye bye bob
    pause 123

