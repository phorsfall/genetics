

class Population
  def evolve
    loop do
      break if done?
      prepare # Hook for modules to do any work they need at the start of each iteration.
      next_generation
    end
  end
  
  def breed(p1, p2)
    # Mutate, crossover etc.
    # Could be pluggable.
  end
end

# Rank-based.
# Roulette.
# Truncation.
# Tournament
# Competitive. (Tournament)

module Selection
  def prepare
    sort!
    
    # Or create mating pool here.
    
  end

  def select
    # Return an individual using this algorithm.
    # Or return from mating pool.
  end
  
  def parents
    # Could return 2 individuals.
    # Or maybe breeding an individual with itself is ok...
  end
  
  # Or ...
  
  def create_mating_pool
    # Could be threaded in the case of tournament selection.
  end
end

# This is generational. i.e. replace the current gen with a new one.
# An alternative is steady-state.
module Replacement
  def next_generation
    # Assumes population is sorted by fitness, which isn't always possible. e.g. Competitive-selection.
    ng = self[0..1] # Elitism.
    ng << breed(select, select) while ng.size < size
    replace(ng)
  end
end
