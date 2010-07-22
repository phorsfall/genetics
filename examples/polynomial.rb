require '../tree'
require '../population'
require 'pp'

class PolynomialTree < Tree
  args :x, :y

  def self.data
    @data ||= begin
      f = lambda { |x,y| x**2 + 2*y + 3*x + 5 }
      Array.new(100) { [x = rand(40), y = rand(40), f.call(x,y)] }
    end
  end

  def fitness
    d = 0
    self.class.data.each do |x, y, expected|
      d += (expected - evaluate(:x => x, :y => y)).abs
    end
    d
  end
end

population = Population.new(PolynomialTree)
tree = population.evolve
pp tree.genes