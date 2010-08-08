module SegaranHelpers
  private

  def weighted_rand(pexp = 0.8)
    (Math.log10(rand) / Math.log10(pexp)).to_i
  end
end

module SegaranRankSelection
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

module SegaranVersusTournament
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
         result = tree1.fight(tree2)
         scores[tree1_index] += result[0]
         scores[tree2_index] += result[1]
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