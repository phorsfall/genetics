class Array
  # Ruby 1.9-esque method for selected a random item.
  def sample
    self[rand(self.length)]
  end
end

class Tree
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

  def self.node_type_selector(max_depth)
    # These are relative, it's not nessacary for them to total one.
    fpr = 0.5  # Probability of function
    apr = 0.25 # Probability of arg
    lpr = 0.25 # Probability of literal

    # TODO: Extract the creation of the nodes hash in to a method.
    if max_depth.zero?
      @end_node_selector ||= begin
        nodes = {}
        nodes[:call] = fpr unless function_names(true).empty?
        nodes[:arg] = apr unless class_args.empty?
        nodes[:lit] = lpr unless class_literals.empty?
        RouletteWheel.new(nodes)
      end
    else
      @node_selector ||= begin
        nodes = {}
        nodes[:call] = fpr unless functions.empty?
        nodes[:arg] = apr unless class_args.empty?
        nodes[:lit] = lpr unless class_literals.empty?
        RouletteWheel.new(nodes)
      end
    end
  end

  def self.random_node_type(max_depth)
    node_type_selector(max_depth).sample
  end

  def self.random_node(max_depth = 4)
    case random_node_type(max_depth)
    when :call
      function_name = function_names.sample
      function = functions[function_name]
      arg_count = function[:proc].arity
      # Handle lambdas with no goal posts in Ruby 1.8.
      # i.e. lambda {}.arity == -1
      arg_count = 0 if arg_count == -1
      # Handle the extra parameter lazy functions accept.
      arg_count -= 1 if function[:options] && function[:options][:lazy]
      args = Array.new(arg_count) { random_node(max_depth - 1) }
      [:call, function_name] + args
    when :arg
      [:arg, class_args.sample]
    when :lit
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
    @args || []
  end

  def self.class_literals
    @literals || []
  end

  def self.functions
    @custom_functions || {}
  end

  def self.function_names(terminal = false)
    # HACK: Experimenting with the idea of allowing function with an arity of 0 to be terminals.
    # This is certanily the wrong place to put it.
    # TODO: Add the normalized arity of a function to the @custom_functions hash.
    # (i.e. Having taken Ruby version and lazy/not lazy into account.)
    # We won't duplicate it here, and we also won't need to recalculate it each time
    # we generate a node.
    if terminal
      functions.select do |key, value|
        proc = value[:proc]
        if value[:options] && value[:options][:lazy]
          proc.arity == 1
        else
          proc.arity.zero?
        end
      end.keys
    else
      functions.keys
    end
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