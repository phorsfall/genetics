require "test_helper"

class VersusTournamentSelectionTest < Test::Unit::TestCase
  def test_versus_tournament_selection
    population = Population.new(Player, :select_with => VersusTournament)
    assert_nothing_raised { population.evolve(1) }
  end
end