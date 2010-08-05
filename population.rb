class Population < Array
  def initialize(klass, options = {})
    @klass = klass
    @population_size = options[:size] || 100
    @generation = 0
    extend options[:select_with] || SegaranSelection
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
    n == 1 ? @ranked_population.first : @ranked_population[0..(count-1)]
  end

  def parents
    [@ranked_population[weighted_rand], @ranked_population[weighted_rand]]
  end
end

# Deterministic tournament without replacement.
module Tournament
  def prepare
    @breeding_pool = []
    shuffle!
    each_slice(20) { |round| @breeding_pool << round.min }
    # One of the advantages of tournament selection is not having to
    # sort the population. Perhaps we could delay performing this sort
    # until we know it's required (i.e. When fittest is called with
    # args.) and use min/max when we need to the single fittest individual.
    # (As just finding min/max is quicker than re-ordering.)
    sort! # Sort population so fittest can return appropriate individuals.
  end

  def fittest(count = nil)
    count.nil? ? first : self[0..(count-1)]
  end

  def parents
    Array.new(2) { @breeding_pool.sample }
  end
end

module VersusTournament
  def prepare
    @breeding_pool = []
    scores = Hash.new(0)
    shuffle!
    each_slice(10) do |round|
      round.each do |t1|
        round.each do |t2|
          next if t1 == t2

          case t1.fight(t2)
          when :win
            scores[t1] += 4
          when :loose
            scores[t2] += 4
          when :draw
            scores[t1] += 1
            scores[t2] += 1
          end
        end
      end
      # Sort by score and add the winner of this round to the pool.
      @breeding_pool << scores.to_a.sort { |a,b| a[1] <=> b[1] }.transpose[0].last
      scores.clear
    end
  end

  # We don't know who is fittest, returning members of the breeding pool will do.
  # One idea is to run a round where everyone fights everyone
  # else when this method is called.
  # Although, this method is called when elitism is used during selection, so this
  # would need to be used without elitism. Maybe selection and replacement modules
  # should be bundled together into sensible units.
  # Using facets modules addition could give something like:
  # VersusTournament = VersusTournament + GenerationalReplacementWithoutElitism.
  def fittest(count = nil)
    count.nil? ? @breeding_pool.sample : @breeding_pool[0..(count-1)]
  end

  def parents
    Array.new(2) { @breeding_pool.sample }
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
