# Hi John

This is a [Genetic Programming](http://en.wikipedia.org/wiki/Genetic_programming) library for Ruby.

> In artificial intelligence, genetic programming (GP) is an evolutionary algorithm-based methodology inspired by biological evolution to find computer programs that perform a user-defined task.

I really don't know what I'll do with this in the future; I'm just having fun. It's usable though (at least for toy problems), and interesting to play with.

# Requirements

* Ruby 1.9.2

It'll probably work with any version of 1.9, I just happen to be using 1.9.2. It doesn't work with 1.8.

To run the tests:

* Mocha

# Examples

There are a few examples of using the library to evolve various programs in the `examples` directory.

`xor.rb`

Evolves an XOR function using just NAND. This is the simplest example and a good place to start, you'll be able to figure out what's happening.

`polynomial.rb`

Finds the function used to generate the sample data. Think fitting a line to a curve, or symbolic regression if you're a statistician.

`ant_trail.rb`

A solution to the Santa Fe Ant Trail problem, a textbook GP problem. Ants are set on a grid along with a trail of food. The ants can turn left and right, move forward and tell whether there is food directly ahead. The idea is to evolve an ant capable of following the trail, collecting all the food on the grid along the way.

    git clone http://github.com/phorsfall/genetics.git
    cd genetics
    # Evolve a new ant, showing the fittest ant from each generation navigate the trail
    ruby examples/ant_trail/ant_trail.rb -d
    # Watch a previously evolved solution
    ruby examples/ant_trail/ant_trail.rb -r

Thanks for reading, I'll see you tomorrow evening.

Paul