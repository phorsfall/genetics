require "test_helper"

class SegaranSelectionTest < Test::Unit::TestCase
  def test_segaran_rank_selection
    population = Population.new(SquareTree, :select_with => SegaranRankSelection)
    assert_nothing_raised { population.evolve(1) }
  end

  def test_segaran_versus_tournament_selection
    population = Population.new(Player, :select_with => SegaranVersusTournament)
    assert_nothing_raised { population.evolve(1) }
  end
end