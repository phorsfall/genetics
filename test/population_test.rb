require "test_helper"

class PopulationTest < Test::Unit::TestCase
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
    population = Population.new(BasicTree)
    population.evolve(1)
    assert_equal 1, population.generation
    population.evolve(2)
    assert_equal 3, population.generation
  end

  def test_mean_depth
    population = Population.new(SquareTree, :size => 2)
    expected_mean_depth = (population[0].depth + population[1].depth) / 2.0
    assert population.mean_depth.is_a?(Float)
    assert_equal expected_mean_depth, population.mean_depth
  end

  def test_mean_fitness_when_tree_implements_fitness
    population = Population.new(SquareTree, :size => 2)
    expected_mean_fitness = (population[0].fitness + population[1].fitness) / 2.0
    assert population.mean_fitness.is_a?(Float)
    assert_equal expected_mean_fitness, population.mean_fitness
  end

  def test_mean_fitness_when_tree_does_not_implement_fitness
    population = Population.new(Player, :size => 1)
    assert_nil population.mean_fitness
  end
end