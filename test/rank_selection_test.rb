require "test_helper"

class RankSelectionTest < Test::Unit::TestCase
  def test_evolution
    population = Population.new(SquareTree, :select_with => Rank, :size => 10)
    assert_nothing_raised { population.evolve(1) }
    assert_instance_of SquareTree, population.fittest
  end

  def test_proability_distribution
    population = Population.new(SquareTree, :select_with => Rank, :size => 10)
    assert_in_delta 0.18, population.probability_distribution[0], 1e-10
    assert_in_delta 0.3276, population.probability_distribution[1], 1e-10
    assert_in_delta 0.448632, population.probability_distribution[2], 1e-10
  end

  def test_random_index
    population = Population.new(SquareTree, :select_with => Rank)
    population.stubs(:probability_distribution).returns([0.2, 0.5, 0.8, 1.0])
    population.stubs(:rand).returns(0.1, 0.4, 0.7, 0.9)
    assert_equal 0, population.random_index
    assert_equal 1, population.random_index
    assert_equal 2, population.random_index
    assert_equal 3, population.random_index
  end

  def test_random_index_boundaries
    population = Population.new(SquareTree, :select_with => Rank)
    population.stubs(:probability_distribution).returns([0.2, 0.5, 0.8, 1.0])
    population.stubs(:rand).returns(0.0, 0.2, 0.5)
    assert_equal 0, population.random_index
    assert_equal 1, population.random_index
    assert_equal 2, population.random_index
  end

  def test_random_index_when_cumulative_probability_less_than_one
    population = Population.new(SquareTree, :select_with => Rank)
    population.stubs(:probability_distribution).returns([0.2, 0.4, 0.8])
    population.stubs(:rand).returns(0.8, 0.7)
    assert_equal 2, population.random_index
  end
end
