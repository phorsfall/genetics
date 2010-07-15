class Tree
  def initialize(tree)
    @tree = tree
  end

  def evaluate(*args)
    evaluate_node(@tree, args)
  end

  private

  def function(name)
    {
      :+ => proc { |a,b| a + b },
      :* => proc { |a,b| a * b }
    }[name]
  end

  def evaluate_node(node, args)
    # [:call, :+, 1, 2]
    # [:lit, 1]
    # [:arg, 0]
    case node.first
    when :call
      call_args = node[2..-1].map { |n| evaluate_node(n, args) }
      function(node[1]).call(*call_args)
    when :lit
      node[1]
    when :arg
      args[node[1]]
    end
  end
end