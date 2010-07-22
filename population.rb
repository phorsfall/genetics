class Population
  def initialize(klass)
    @klass = klass
  end

  def evolve
    population_size = 500
    population = Array.new(population_size) { @klass.generate }

    500.times do
      population.sort!
      break if population.first.fitness.zero?
      next_generation = population[0..1]

      while next_generation.size < population_size
        if rand > 0.05
          next_generation << population[weighted_rand].mutate.cross_with(population[weighted_rand])
        else
          next_generation << @klass.generate
        end
      end
      population = next_generation
    end

    population.first
  end

  private

  def weighted_rand(pexp = 0.8)
    (Math.log10(rand) / Math.log10(pexp)).to_i
  end
end