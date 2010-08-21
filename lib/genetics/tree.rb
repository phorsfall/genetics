class Array
  # Ruby 1.9-esque method for selected a random item.
  def sample
    self[rand(self.length)]
  end
end

class Tree
  @@default_args = [:x, :y]
  @@default_literals = (0..9).to_a
  # TODO: Use lambda not proc.
  # Not sure why I used proc, but it changes to a synonym of
  # Proc.new in Ruby 1.9 so stick with lambda.
  @@default_functions = {
    :+ => { :proc => proc { |a,b| a + b } },
    :* => { :proc => proc { |a,b| a * b } },
    :- => { :proc => proc { |a,b| a - b } }
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

  def memoized_fitness
    @fitness ||= fitness
  end

  class << self
    alias_method :arg, :args
  end

  def self.literals(range)
    @literals = range.to_a
  end

  def self.function(name, options = nil, &block)
    @custom_functions ||= {}
    @custom_functions[name] = { :proc => block }
    @custom_functions[name][:options] = options if options
  end

  def self.generate
    new random_node
  end

  def self.random_node(max_depth = 4)
    fpr = 0.5 # Probability of function
    apr = 0.5 # Probability of arg

    if rand < fpr && max_depth > 0
      function_name = function_names.sample
      # TODO: Fix that this will be off by one for lazy functions.
      # Because of the extra lambda passed to eval nodes.
      arg_count = functions[function_name][:proc].arity
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

  def <=>(other)
    memoized_fitness <=> other.memoized_fitness
  end

  def depth(node = genes)
    node[0] == :call ? (node[2..-1].map { |n| depth(n) }.max || -1) + 1 : 0
  end

  # Does overriding these 3 suggest Tree should inherit from array?
  def ==(other)
    genes == other.genes
  end

  def eql?(other)
    self == other
  end

  def hash
    genes.hash
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
      if gene1[0] == :call && gene2[0] == :call && !gene2[2..-1].empty?
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
      func = self.class.functions[node[1]]
      call_args = nil

      if func[:options] && func[:options][:lazy]
        call_args = node[2..-1]
        call_args << lambda { |node| evaluate_node(node, args) }
        # TODO: Test if Ruby 1.9 allows blocks to be passed to lambdas.
        # This would mean that when defining a lazy function, you didn't have
        # to add the extra param for the lambda you use to eval a node.
        # Which would simplify the checking of arity as it wouldn't need
        # to allow for this extra arg for lazy functions.
      else
        call_args = node[2..-1].map { |n| evaluate_node(n, args) }
      end

      # I _think_ this requires RUBY_VERSION >= 1.8.7.
      instance_exec *call_args, &func[:proc]
    when :lit
      node[1]
    when :arg
      args[node[1]]
    end
  end
end