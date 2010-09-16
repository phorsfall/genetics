$:.unshift('lib')

require "rubygems"
require "genetics"
require "gosu"
require "chipmunk"
require "pp"

require_relative "cart_pole/cart"
require_relative "cart_pole/controller"
require_relative "cart_pole/gosu_simulation"
require_relative "cart_pole/simulation"

# http://is.gd/f69Bm

if __FILE__ == $0
  require 'optparse'
  options = { :mode => :run }

  OptionParser.new do |opts|
    opts.on("-i", "--interactive", "Be an ant, explore the trail") { options[:mode] = :interactive }
    opts.on("-e", "--evolve", "Evolve an ant population") { options[:mode] = :evolve }
    opts.on("-r", "--run", "Watch a previously evolved ant run the trail") { options[:mode] = :run }
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  case options[:mode]
  when :interactive
    s = GosuSimulation.new
    #s.simulation.unbalance(1)
    s.show
  when :evolve
    population = Population.new(Controller, :size => 100, :select_with => Rank)
    population.evolve(20) do |g|
      puts g.fittest.fitness
      #print "."
      #$stdout.flush
    end
    pp population.fittest.genes
  when :run
    controller = Controller.new([:arg, :angular_velocity])
    # controller = Controller.new([:call,
    #  :*,
    #  [:arg, :position],
    #  [:call,
    #   :+,
    #   [:call,
    #    :*,
    #    [:arg, :angular_velocity],
    #    [:call, :+, [:lit, 6.0], [:lit, 4.0]]],
    #   [:arg, :angle]]])
    s = GosuSimulation.new(controller)
    #s.simulation.unbalance
    s.show
  end
end
