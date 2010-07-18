require 'pp'
require 'tree'

def hidden_function(x, y)
  x**2 + 2*y + 3*x + 5
end

def dataset
  @dataset ||= begin
    rows = []
    200.times do
      x, y = rand(40), rand(40)
      rows << [x, y, hidden_function(x, y)]
    end
    rows
  end
end

def score(tree, dataset)
  dif = 0
  dataset.each do |row|
    v = tree.evaluate(row[0], row[1])
    dif += (v-row[2]).abs
  end
  dif
end

def mutate(tree, pc, prob = 0.1)
  if rand < prob
    Tree.random(pc)
  else
    result = tree.clone
    if result.is_a? Node
      result.children.map! { |child| mutate(child, pc, prob) }
    end
    result
  end
end

def crossover(t1, t2, prob = 0.7, top = true)
  if rand < prob && !top
    t2.clone
  else
    result = t1.clone
    if t1.is_a?(Node) && t2.is_a?(Node)
      result.children.map! { |child| crossover(child, t2.children[rand(t2.children.length)], prob, false) }
    end
    result
  end
end

def evolve(pc, popsize, maxgen=500, mutationrate=0.3, breedingrate=0.2, pexp=0.8, pnew=0.01)
  population = Array.new(popsize) { Tree.random(pc) }
  
  scores = []
  
  0.upto(maxgen-1) do |i|
    scores = population.each.map { |tree| [score(tree, dataset), tree] }
    scores.sort! { |a,b| a[0] <=> b[0] }
    
    puts scores[0..5].map { |s| s[0] }.inspect
    #scores[0][1].display
    break if scores[0][0] == 0
    
    
    newpop = [scores[0][1], scores[1][1]]
    
    while newpop.length < popsize
      if rand > pnew
        newpop << mutate(crossover(scores[rand_log(pexp)][1], scores[rand_log(pexp)][1], breedingrate), pc, mutationrate)
        #newpop << crossover(scores[rand_log(pexp)][1], scores[rand_log(pexp)][1], breedingrate)
      else
        newpop << Tree.random(pc)
      end
    end
    
    population = newpop
  end
  
  scores[0][1].display
  return scores[0][1]
end

def rand_log(pexp)
  (Math.log10(rand)/Math.log10(pexp)).to_i
end

winner = evolve(2, 500)

puts dataset[0].inspect
puts winner.evaluate(dataset[0][0], dataset[0][1])



