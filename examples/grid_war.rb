require '../tree'
require '../population'
require 'pp'

class GridWarTree < Tree
  args :x1, :y1, :x2, :y2

  def fight(competitor)
    gene_length = genes.flatten.length
    competitor_gene_length = competitor.genes.flatten.length
    if gene_length < competitor_gene_length
      :win
    elsif competitor_gene_length > gene_length
      :loose
    else
      :draw
    end
    #[:win, :loose, :draw].sample
  end
end

population = Population.new(GridWarTree, Tournament)
tree = population.evolve
pp tree.genes