$:.unshift("lib")
require "genetics"
require "pp"

class Xor < Tree
  args :a, :b
  #function(:not) { |a| !a }
  #function(:and) { |a,b| a && b }
  #function(:or)  { |a,b| a || b }
  function(:nand) { |a,b| !(a && b) }
  #function(:nor) { |a,b| !(a || b) }

  def fitness
    @fitness ||= begin
      score = [
        [false, false],
        [false, true],
        [true, false],
        [true, true]
      ].inject(0) do |s, (a, b)|
        s += 1 if evaluate(:a => a, :b => b) == a^b
        s
      end
      4 - score
    end
  end

  def ideal?
    fitness.zero?
  end
end


population = Population.new(Xor, :select_with => Rank, :size => 50)

population.evolve(1000) do |g|
  print "."
  $stdout.flush
end

winner = population.fittest
puts
pp winner.genes
puts

[
  [false, false],
  [false, true],
  [true, false],
  [true, true]
].each do |a,b|
  puts "#{a.to_s.ljust(5)} | #{b.to_s.ljust(5)} | #{winner.evaluate(:a => a, :b => b)}"
end
