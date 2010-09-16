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
    s.show
  when :evolve
    population = Population.new(Controller, :size => 100, :select_with => Tournament)
    population.evolve do |g|
      print "."
      $stdout.flush
    end
    pp population.fittest.genes
  when :run
    controller = Controller.new([:call,
     :+,
     [:call,
      :*,
      [:call,
       :*,
       [:call,
        :+,
        [:call, :+, [:call, :-, [:lit, -1.0], [:arg, :angle]], [:arg, :angle]],
        [:call, :*, [:lit, 0.4], [:call, :+, [:lit, 0.7], [:lit, 0.6]]]],
       [:arg, :angle]],
      [:call,
       :*,
       [:call, :*, [:lit, 0.5], [:arg, :position]],
       [:call, :+, [:lit, 0.4], [:arg, :position]]]],
     [:call,
      :*,
      [:call,
       :*,
       [:call, :*, [:lit, 0.5], [:arg, :position]],
       [:call, :+, [:lit, 0.4], [:arg, :position]]],
      [:call, :+, [:arg, :angle], [:arg, :angular_velocity]]]])
    s = GosuSimulation.new(controller)
    s.show
  end
end
