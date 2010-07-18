class FunctionWrapper
  attr_accessor :name, :child_count, :block
  def initialize(name, child_count, &block)
    @name = name
    @child_count = child_count
    @block = block
  end

  def call(*args)
    block.call(*args)
  end
end

class Node
  attr_accessor :function_wrapper, :children
  
  def initialize(function_wrapper, *children)
    @function_wrapper = function_wrapper
    @children = children
  end
  
  def initialize_copy(source)
    super
    @children = @children.map { |c| c.clone }
  end
  
  def evaluate(*args)
    evaled_args = children.map { |child| child.evaluate(*args) }
    function_wrapper.call(*evaled_args)
  end
  
  def display(indent = 0)
    puts " "*indent + function_wrapper.name
    children.each { |child| child.display(indent + 1) }
  end
end

class Param < Struct.new(:index)
  def evaluate(*input)
    input[index]
  end
  
  def display(indent = 0)
    puts " "*indent + "arg " + index.to_s
  end
end

class Const < Struct.new(:value)
  def evaluate(*input)
    value
  end
  
  def display(indent = 0)
    puts " "*indent + value.to_s
  end
end

module Function
  def self.add
    @add ||= FunctionWrapper.new("add", 2) { |a, b| a + b }
  end
  
  def self.subtract
    @subtract ||= FunctionWrapper.new("subtract", 2) { |a, b| a - b }
  end
  
  def self.multiply
    @multiply ||= FunctionWrapper.new("multiply", 2) { |a, b| a * b }
  end
  
  def self.if
    @iff ||= FunctionWrapper.new("if", 3) { |a, b, c| a > 0 ? b : c }
  end

  # class << self
  #   alias_method :_if, :if
  # end

  def self.gt
    @gt ||= FunctionWrapper.new("isgreater", 2) { |a, b| a > b ? 1 : 0 }
  end

  def self.all
    [add, subtract, multiply]#, self.if, gt]
  end
end

module Tree
  def self.random(pc, max_depth = 4, fpr = 0.5, ppr = 0.6)
    if rand < fpr && max_depth > 0
      function = Function.all[rand(Function.all.length)]
      children = []
      function.child_count.times { children << random(pc, max_depth-1, fpr, ppr) }
      Node.new(function, *children)
    elsif rand < ppr
      Param.new(rand(pc))
    else
      Const.new(rand(10))
    end
  end
end
