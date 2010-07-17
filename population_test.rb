require 'rubygems'
require 'test/unit'
require 'redgreen'
require 'tree'
require 'population'

class PopulationTest < Test::Unit::TestCase
  class SquareTree < Tree
    arg :x

    DATA = { 1 => 1, 2 => 4, 3 => 9, 4 => 16, 5 => 25, 6 => 36 }

    def fitness
      d = 0
      self.class::DATA.each do |x, expected|
        d += (expected - evaluate(:x => x)).abs
      end
      d
    end
  end

  def test_evolving_a_population
    population = Population.new(SquareTree)
    tree = population.evolve
    assert_equal 1, tree.evaluate(:x => 1)
    assert_equal 4, tree.evaluate(:x => 2)
    assert_equal 9, tree.evaluate(:x => 3)
    assert_equal 16, tree.evaluate(:x => 4)
  end

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

  def test_solving_a_polynomial
    population = Population.new(PolynomialTree)
    tree = population.evolve
    assert_equal 11, tree.evaluate(:x => 1, :y => 1)
    assert_equal 21, tree.evaluate(:x => 2, :y => 3)
    assert_equal 33, tree.evaluate(:x => 3, :y => 5)
    assert_equal 55, tree.evaluate(:x => 5, :y => 5)
  end
end