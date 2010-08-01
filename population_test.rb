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

    def ideal?
      fitness.zero?
    end
  end

  def test_evolving_a_population
    population = Population.new(SquareTree)
    tree = population.evolve.fittest
    assert_equal 1, tree.evaluate(:x => 1)
    assert_equal 4, tree.evaluate(:x => 2)
    assert_equal 9, tree.evaluate(:x => 3)
    assert_equal 16, tree.evaluate(:x => 4)
  end

  def test_specifying_the_population_size
    population = Population.new(SquareTree, :size => 5)
    assert_equal 5, population.size
  end

  def test_specifying_the_number_of_generations_to_evolve
    population = Population.new(SquareTree)
    population.evolve(1)
    assert 1, population.generation
    population.evolve(2)
    assert 3, population.generation
  end

  def test_tournament_selection
    population = Population.new(SquareTree, :selection_module => Tournament)
    assert population.evolve.fittest.fitness.zero?
  end
end