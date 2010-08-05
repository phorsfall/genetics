class Population < Array
  def initialize(klass, options = {})
    @klass = klass
    @population_size = options[:size] || 100
    @generation = 0
    extend options[:select_with] || SegaranRankSelection
    extend GenerationalReplacement # This will be configurable at runtime.
    super(@population_size) { @klass.generate }
  end

  attr_reader :generation

  def evolve(generations = 60)
    generations.times do
      # Hook for modules to do any work they need at the start of each iteration.
      # Once called, it's assumed that #parents and #fittest are available.
      prepare
      yield self if block_given?
      break if done?
      generate # Create the next generation.
      @generation += 1
    end
    self
  end

  def breed(p1, p2)
    # Mutate, crossover etc.
    # Could be pluggable.
    if rand > 0.05
      p1.mutate.cross_with(p2)
    else
      @klass.generate
    end
  end

  def done?
    fittest && fittest.respond_to?(:ideal?) && fittest.ideal?
  end
end

# This is generational. i.e. replace the current gen with a new one.
# An alternative is steady-state.
module GenerationalReplacement
  def generate
    next_gen = fittest(2) # Elitism.
    next_gen << breed(*parents) while next_gen.size < size
    replace(next_gen)
  end
end
