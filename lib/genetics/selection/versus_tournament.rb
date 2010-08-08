module VersusTournament
  def prepare
    @breeding_pool = []
    scores = Hash.new(0)
    shuffle!
    each_slice(10) do |round|
      round.each do |t1|
        round.each do |t2|
          next if t1.equal?(t2)
          result = t1.fight(t2)
          scores[t1] += result[0]
          scores[t2] += result[1]
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