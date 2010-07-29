class Population
  def initialize(klass, ranking_module = Fittest)
    @klass = klass
    extend ranking_module
  end

  def evolve
    population_size = 250
    @population = Array.new(population_size) { @klass.generate }

    60.times do
      rank!

      # TODO: This only applies when using Fittest, and I'm not sure there's an equivalent for Tournament.
      # i.e. Is there such a thing as a perfect player in a tournament, or should we just keep evolving?
      #break if population.first.fitness.zero?

      next_generation = @population[0..1]

      while next_generation.size < population_size
        if rand > 0.05
          next_generation << @population[weighted_rand].mutate.cross_with(@population[weighted_rand])
        else
          next_generation << @klass.generate
        end
      end
      @population = next_generation
    end

    @population.first
  end

  private

  def weighted_rand(pexp = 0.8)
    (Math.log10(rand) / Math.log10(pexp)).to_i
  end
end

module Fittest
  def rank!
    @population.sort!
  end
end

module Tournament
  def rank!
    scores = Array.new(@population.size, 0)

    # Is there a built-in (or Facets) function for getting each combination?
    # Array#combination?
    @population.each_with_index do |tree1, tree1_index|
      @population.each_with_index do |tree2, tree2_index|
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

    population_with_scores = @population.zip(scores)
    population_with_scores.sort! { |a,b| b.last <=> a.last }
    @population = population_with_scores.collect { |tree, score| tree }
  end
end