class Tree
  def initialize(tree)
    @tree = tree
  end

  def evaluate(*args)
    args = args.first if args.first.is_a?(Hash)
    evaluate_node(@tree, args)
  end

  def self.generate
    new(random_node)
  end

  def self.random_node(max_depth = 4)
    fpr = 0.5 # Probability of function
    ppr = 0.5 # Probability of param

    if rand < fpr && max_depth > 0
      function_name = function_names[rand(function_names.length)]
      arg_count = function(function_name).arity
      args = Array.new(arg_count) { random_node(max_depth - 1) }
      [:call, function_name] + args
    elsif rand < ppr
      [:arg, 0]
    else
      [:lit, 1]
    end
  end

  private

  FUNCTIONS = {
    :+ => proc { |a,b| a + b },
    :* => proc { |a,b| a * b },
    :- => proc { |a,b| a - b }
  }

  def self.function(name)
    FUNCTIONS[name]
  end

  def self.function_names
    FUNCTIONS.keys
  end

  def evaluate_node(node, args)
    # [:call, :+, 1, 2]
    # [:lit, 1]
    # [:arg, 0]
    case node.first
    when :call
      call_args = node[2..-1].map { |n| evaluate_node(n, args) }
      self.class.function(node[1]).call(*call_args)
    when :lit
      node[1]
    when :arg
      args[node[1]]
    end
  end
end