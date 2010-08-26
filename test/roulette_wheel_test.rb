require "test_helper"

class RouletteWheelTest < Test::Unit::TestCase
  def test_probability_distribution
    rw = RouletteWheel.new(:a => 2, :b => 6, :c => 12)
    assert_equal [[:a, 0.1], [:b, 0.4], [:c, 1.0]], rw.probability_distribution
  end

  def test_selection
    rw = RouletteWheel.new(:a => 2, :b => 6, :c => 12)
    rw.stubs(:rand).returns(0, 0.09, 0.1, 0.5, 0.99999)
    samples = Array.new(5) { rw.sample }
    assert_equal [:a, :a, :b, :c, :c], samples
  end
end
