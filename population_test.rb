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
end