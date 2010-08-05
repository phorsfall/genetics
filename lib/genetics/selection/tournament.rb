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