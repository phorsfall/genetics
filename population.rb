class Population < Array
  def initialize(klass, selection_module = SegaranSelection)
    @population_size = 250
    @klass = klass
    extend selection_module
    super(@population_size) { @klass.generate }
  end

  # See http://www.geneticprogramming.com/Tutorial/
  def evolve(generations = 60)
    generations.times do
      break if done?
      next_generation do |tree1, tree2|
        if rand > 0.05
          tree1.mutate.cross_with(tree2)
        else
          @klass.generate
        end
      end
    end
    self
  end

  alias_method :fittest, :min

  def done?
    fittest && fittest.ideal?
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

  def next_generation
    sort!
    next_generation = self[0..1]
    while next_generation.size < @population_size
      next_generation << yield(self[weighted_rand], self[weighted_rand])
    end
    replace(next_generation)
  end
end

module SegaranTournament
  include SegaranHelpers

  def fittest
    nil
  end

  def next_generation
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
    ranked_population = population_with_scores.collect { |tree, score| tree }

    next_generation = ranked_population[0..1]
    while next_generation.size < @population_size
      next_generation << yield(ranked_population[weighted_rand], ranked_population[weighted_rand])
    end
    replace(next_generation)
  end
end