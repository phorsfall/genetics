class Population < Array
  def initialize(klass, options = {})
    @klass = klass
    @population_size = options[:size] || 100
    extend options[:selection_module] || SegaranSelection
    extend GenerationalReplacement # This will be configurable at runtime.
    super(@population_size) { @klass.generate }
  end

  def evolve(generations = 60)
    generations.times do
      # Hook for modules to do any work they need at the start of each iteration.
      # Once called, it's assumed that #parents and #fittest are available.
      prepare
      break if done?
      generate # Create the next generation.
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

  alias_method :fittest, :min

  def done?
    fittest && fittest.respond_to?(:ideal?) && fittest.ideal?
  end
end

module SegaranHelpers
  private

  def weighted_rand(pexp = 0.8)
    (Math.log10(rand) / Math.log10(pexp)).to_i
  end
end

module SegaranSelection
  include SegaranHelpers

  def prepare
    sort!
  end

  def fittest(count = 1)
    # The populate was already sorted when prepare was called,
    # so is already sorted by fittness.
    count == 1 ? first : self[0..(count-1)]
  end

  def parents
    # Maybe this could ensure 2 different parents are returned.
    [self[weighted_rand], self[weighted_rand]]
  end
end

module SegaranTournament
  include SegaranHelpers

  def prepare
    scores = Array.new(size, 0)

     # Is there a built-in (or Facets) function for getting each combination?
     # Array#combination?
     each_with_index do |tree1, tree1_index|
       each_with_index do |tree2, tree2_index|
         next if tree1 == tree2

         # Only play against each other once.
         # This risks evolving a program that is only successful playing as
         # either player 1 OR player 2.
         #next if tree1_index > tree2_index

         # Why not use a hash for scoring, with the tree as the key?
         case tree1.fight(tree2)
         when :win
           # Need to make the scoring configurable.
           scores[tree1_index] += 4
         when :loose
           scores[tree2_index] += 4
         when :draw
           scores[tree1_index] += 1
           scores[tree2_index] += 1
         end
       end
     end

     population_with_scores = zip(scores)
     population_with_scores.sort! { |a,b| b.last <=> a.last }
     @ranked_population = population_with_scores.collect { |tree, score| tree }
  end

  def fittest(n = 1)
    n = 1 ? @ranked_population.first : @ranked_population[0..(count-1)]
  end

  def parents
    [@ranked_population[weighted_rand], @ranked_population[weighted_rand]]
  end
end

# This is generational. i.e. replace the current gen with a new one.
# An alternative is steady-state.
module GenerationalReplacement
  def generate
    # Assumes population is sorted by fitness, which isn't always possible. e.g. Competitive-selection.
    next_gen = self[0..1] # Elitism.
    next_gen << breed(*parents) while next_gen.size < size
    replace(next_gen)
  end
end
