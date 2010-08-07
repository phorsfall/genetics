require 'benchmark'

# Non-linear ranking selection. Uses roulette selection.
module Rank
  def prepare
    sort!
  end

  def fittest(count = nil)
    count.nil? ? first : self[0..(count-1)]
  end

  def parents
    Array.new(2) { self[random_index] }
  end

  def random_index
    # rand returns a number < 1. Ideally the last probability in
    # the distribution would be 1.0, so we'd always select an
    # index. However, for small populations, the sum of all
    # probabilities is < 1. Keep selecting random numbers until
    # one is picked which is not off the end of the distribution.
    while (r = rand) >= probability_distribution.last; end

    probability_distribution.each_with_index do |cpr, index|
      return index if r < cpr
    end
    raise "Unreachable"
  end

  def probability_distribution
    @probability_distribution ||= (1..size).map { |rank| cumulative_probability(rank) }
  end

  def cumulative_probability(rank)
    (1..rank).inject(0) { |sum, r| sum + probability(r) }
  end

  def probability(rank, q = 0.18)
    q * (1 - q) ** (rank-1)
  end
end