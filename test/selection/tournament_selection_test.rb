require "test_helper"

class TournamentSelectionTest < Test::Unit::TestCase
  def test_tournament_selection
    population = Population.new(SquareTree, :select_with => Tournament)
    assert population.evolve.fittest.fitness.zero?
  end
end