$:.unshift('lib')
require 'pp'
require 'genetics'

class PolynomialTree < Tree
  args :x, :y
  literals 1..9
  function(:+) { |a,b| a + b }
  function(:*) { |a,b| a * b }
  function(:-) { |a,b| a - b }

  def self.data
    @data ||= begin
      f = lambda { |x,y| x**2 + 2*y + 3*x + 5 }
      Array.new(100) { [x = rand(40), y = rand(40), f.call(x,y)] }
    end
  end

  def fitness
    @fitness ||= begin
      d = 0
      self.class.data.each do |x, y, expected|
        d += (expected - evaluate(:x => x, :y => y)).abs
      end
      d
    end
  end

  def ideal?
    fitness.zero?
  end
end

population = Population.new(PolynomialTree, :select_with => Tournament)

population.evolve(1000) do |g|
  puts g.fittest.fitness
  puts "Total population: #{g.size}. Duplicates: #{g.size - g.uniq.size}"
end

pp population.fittest.genes