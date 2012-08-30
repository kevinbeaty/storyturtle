[![Build Status](https://secure.travis-ci.org/kevinbeaty/storyturtle.png)](http://travis-ci.org/kevinbeaty/storyturtle)

Story Turtle is a first introduction to programming for
my kids (ages 8 and 10).  The grammer, images, and [example
stories][1] were their own creation, as described below.


## Writing a Story

The game board is a square. The top-left is `at 0 0`, and the bottom 
right is `at 300 300`.  You can add characters to the board by giving
them a name and telling them where to start. You can tell them to move
and tell them to die.  They can also say things. Each step is separated
by blank lines.

Example ([Turtle Diner][2]):

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

[1]: http://simplectic.com/story_turtle
[2]: http://simplectic.com/story_turtle/turtle_diner.html

