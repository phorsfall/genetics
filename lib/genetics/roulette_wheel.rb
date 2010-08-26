class RouletteWheel
  attr_reader :probability_distribution

  def initialize(items_with_weights)
    cumulative_probabilities = []
    total_weight = items_with_weights.values.inject(0.0) do |acc, weight|
      pr = acc + weight
      cumulative_probabilities << pr
      pr
    end
    # Normalize probabilities.
    cumulative_probabilities.map! { |p| p / total_weight }
    @probability_distribution = items_with_weights.keys.zip(cumulative_probabilities)
  end

  def sample
    r = rand
    probability_distribution.each do |item, pr|
      return item if r < pr
    end
    raise "Unreachable"
  end
end