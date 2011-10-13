$:.unshift('lib')

require "rubygems"
require "genetics"
require "gosu"
require "chipmunk"
require "pp"

class ERCG
  def to_a
    self
  end

  def sample
    rand
  end

  def empty?
    false
  end
end

require_relative "cart_pole/cart"
require_relative "cart_pole/controller"
require_relative "cart_pole/gosu_simulation"
require_relative "cart_pole/simulation"

# http://is.gd/f69Bm

if __FILE__ == $0
  require 'optparse'
  options = { :mode => :run }

  OptionParser.new do |opts|
    opts.on("-i", "--interactive", "Balance the pole with the arrow keys") { options[:mode] = :interactive }
    opts.on("-e", "--evolve", "Evolve a new controller") { options[:mode] = :evolve }
    opts.on("-r", "--run", "Watch a previously evolved controller") { options[:mode] = :run }
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  case options[:mode]
  when :interactive
    s = GosuSimulation.new
    s.simulation.unbalance
    s.show
  when :evolve
    population = Population.new(Controller, :size => 200, :select_with => Tournament)
    population.evolve(10000) do |g|
      puts g.fittest.fitness
      pp g.fittest.genes if (g.generation%10).zero?
      # print "."
      # $stdout.flush
    end
    pp population.fittest.genes
  when :run
    controller = Controller.new([:call,
     :+,
     [:arg, :angle],
     [:call, :*, [:lit, 0.36557278204818777], [:arg, :angular_velocity]]])
    s = GosuSimulation.new(controller)
    s.simulation.unbalance(-1)
    s.show
  end
end
