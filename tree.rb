class Array
  # Ruby 1.9-esque method for selected a random item.
  def sample
    self[rand(self.length)]
  end
end

class Tree
  @@default_args = [:x, :y]
  @@default_literals = (0..9).to_a
  @@default_functions = {
    :+ => proc { |a,b| a + b },
    :* => proc { |a,b| a * b },
    :- => proc { |a,b| a - b }
  }

  def initialize(tree)
    @tree = tree
  end

  def evaluate(args = {})
    evaluate_node(@tree, args)
  end

  def self.args(*args)
    @args = args
  end

  class << self
    alias_method :arg, :args
  end

  def self.literals(range)
    @literals = range.to_a
  end

  def self.function(name, &block)
    @custom_functions ||= {}
    @custom_functions[name] = block
  end

  def self.generate
    new random_node
  end

  def self.random_node(max_depth = 4)
    fpr = 0.5 # Probability of function
    apr = 0.5 # Probability of arg

    if rand < fpr && max_depth > 0
      function_name = function_names.sample
      arg_count = functions[function_name].arity
      arg_count = 0 if arg_count == -1
      args = Array.new(arg_count) { random_node(max_depth - 1) }
      [:call, function_name] + args
    elsif rand < apr
      [:arg, class_args.sample]
    else
      [:lit, class_literals.sample]
    end
  end

  def mutate
    self.class.new self.class.mutate_gene(@tree)
  end

  def cross_with(other)
    self.class.new self.class.cross_genes(@tree, other.genes)
  end

  def genes
    @tree
  end

  private

  def self.mutate_gene(gene)
    if rand < 0.3
      random_node
    else
      return gene.clone unless gene[0] == :call
      gene[0..1] + gene[2..-1].map { |g| mutate_gene g }
    end
  end

  def self.cross_genes(gene1, gene2, top = true)
    if rand < 0.7 && !top
      gene2.clone
    else
      if gene1[0] == :call && gene2[0] == :call
        gene1[0..1] + gene1[2..-1].map { |g| cross_genes(g, gene2[2..-1].sample, false) }
      else
        gene1.clone
      end
    end
  end

  def self.class_args
    @args || @@default_args
  end

  def self.class_literals
    @literals || @@default_literals
  end

  def self.functions
    @custom_functions ? @@default_functions.merge(@custom_functions) : @@default_functions
  end

  def self.function_names
    functions.keys
  end

  def evaluate_node(node, args)
    # [:call, :+, [:lit, 1], [:lit, 2]]
    # [:lit, 1]
    # [:arg, 0]
    case node.first
    when :call
      call_args = node[2..-1].map { |n| evaluate_node(n, args) }
      self.class.functions[node[1]].call(*call_args)
    when :lit
      node[1]
    when :arg
      args[node[1]]
    end
  end
end