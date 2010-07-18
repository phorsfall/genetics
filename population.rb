class Population
  def initialize(klass)
    @klass = klass
  end

  def evolve
    population_size = 500
    population = Array.new(population_size) { @klass.generate }
    population_with_fitness = []

    500.times do
      population_with_fitness = population.map { |t| [t.fitness, t] }
      # TODO: Rename to ranked_population.
      population_with_fitness.sort! { |a,b| a[0] <=> b[0] }
      break if population_with_fitness[0][0] == 0
      next_generation = []
      next_generation << population_with_fitness[0][1] << population_with_fitness[1][1]
      while next_generation.size < population_size
        if rand > 0.05
          next_generation << population_with_fitness[weighted_rand][1].mutate.cross_with(population_with_fitness[weighted_rand][1])
        else
          next_generation << @klass.generate
        end
      end
      population = next_generation
    end

    population_with_fitness[0][1]
  end

  private

  def weighted_rand(pexp = 0.8)
    (Math.log10(rand) / Math.log10(pexp)).to_i
  end
end