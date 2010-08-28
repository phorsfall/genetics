require "test_helper"

class TreeTest < Test::Unit::TestCase
  def test_literal
    tree = Tree.new([:lit, 100])
    assert_equal 100, tree.evaluate
  end

  def test_addition
    tree = BasicTree.new([:call, :+, [:lit, 100], [:lit, 200]])
    assert_equal 300, tree.evaluate
  end

  def test_subtraction
    tree = BasicTree.new([:call, :-, [:lit, 10], [:lit, 2]])
    assert_equal 8, tree.evaluate
  end

  def test_multiplication
    tree = BasicTree.new([:call, :*, [:lit, 10], [:lit, 10]])
    assert_equal 100, tree.evaluate
  end

  def test_nested_function_calls
    tree = BasicTree.new([:call, :*, [:call, :+, [:lit, 2], [:lit, 3]], [:call, :+, [:lit, 4], [:lit, 5]]])
    assert_equal 45, tree.evaluate
  end

  def test_x_arg
    tree = BasicTree.new([:arg, :x])
    assert_equal 100, tree.evaluate(:x => 100)
  end

  def test_y_arg
    tree = BasicTree.new([:arg, :y])
    assert_equal 100, tree.evaluate(:y => 100)
  end

  def test_multiplication_with_args
    tree = BasicTree.new([:call, :*, [:arg, :x], [:arg, :y]])
    assert_equal 27, tree.evaluate(:x => 3, :y => 9)
  end

  def test_generating_a_random_tree
    RouletteWheel.any_instance.stubs(:rand).returns(0, 0.9, 0.9)
    Array.any_instance.stubs(:rand).returns(0, 7, 8)
    tree = BasicTree.generate
    assert_equal 15, tree.evaluate
  end

  def test_generating_a_random_tree_with_args
    RouletteWheel.any_instance.stubs(:rand).returns(0, 0.6, 0.6)
    Array.any_instance.stubs(:rand).returns(0, 0, 1)
    tree = BasicTree.generate
    assert_equal 30, tree.evaluate(:x => 10, :y => 20)
  end

  class LiteralsTree < Tree
    literals 40..45
  end

  def test_generating_a_random_tree_with_custom_literals
    RouletteWheel.any_instance.stubs(:rand).returns(0.9)
    Array.any_instance.stubs(:rand).returns(2)
    tree = LiteralsTree.generate
    assert_equal 42, tree.evaluate
  end

  class SingleArgTree < Tree
    arg :x
  end

  def test_subclass_with_single_arg
    tree = SingleArgTree.new([:arg, :x])
    assert_equal 100, tree.evaluate(:x => 100)
  end

  class CustomFunctionsTree < Tree
    function :rand do
      rand(100)
    end

    function :- do |x|
      -x
    end

    function :** do |x, y|
      x**y
    end

    function :+ do |x, y|
      x-y
    end
  end

  def test_rand_function
    CustomFunctionsTree.any_instance.stubs(:rand).returns(42)
    tree = CustomFunctionsTree.new([:call, :rand])
    assert_equal 42, tree.evaluate
  end

  def test_negative_function
    tree = CustomFunctionsTree.new([:call, :-, [:lit, 10]])
    assert_equal -10, tree.evaluate
  end

  def test_power_function
    tree = CustomFunctionsTree.new([:call, :**, [:lit, 2], [:lit, 3]])
    assert_equal 8, tree.evaluate
  end

  def test_generating_a_function_call_to_a_proc_with_an_arity_of_minus_one
    # TODO: Wouldn't it be better just to test that the expected tree is generated here?
    RouletteWheel.any_instance.stubs(:rand).returns(0)
    CustomFunctionsTree.any_instance.stubs(:rand).returns(99)
    CustomFunctionsTree.stubs(:function_names).returns(stub(:sample => :rand))
    tree = CustomFunctionsTree.generate
    assert_equal 99, tree.evaluate
  end

  def test_functions_with_an_arity_of_zero_can_be_used_as_terminals
    RouletteWheel.any_instance.stubs(:rand).returns(0)
    Array.any_instance.stubs(:rand).returns(1, 1, 1, 1, 0)
    tree = CustomFunctionsTree.generate
    assert_equal [:call, :-, [:call, :-, [:call, :-, [:call, :-, [:call, :rand]]]]], tree.genes
  end

  def test_mutation
    BasicTree.stubs(:rand).returns(1, 1, 0)
    RouletteWheel.any_instance.stubs(:rand).returns(0.9)
    Array.any_instance.stubs(:rand).returns(3)
    tree = BasicTree.new([:call, :*, [:lit, 2], [:call, :+, [:lit, 1], [:lit, 1]]])
    assert_equal [:call, :*, [:lit, 2], [:lit, 3]], tree.mutate.genes
  end

  def test_mutation_clones_genes_when_no_mutation_occurs
    BasicTree.stubs(:rand).returns(1)
    #Array.any_instance.stubs(:rand).returns(0)
    original = BasicTree.new([:lit, 5])
    mutant = original.mutate
    assert_equal [:lit, 5], mutant.genes
    assert !mutant.genes.equal?(original.genes)
  end

  def test_crossover
    BasicTree.stubs(:rand).returns(0, 1, 0)
    Array.any_instance.stubs(:rand).returns(0, 1)
    parent1 = BasicTree.new([:call, :+, [:lit, 1], [:lit, 2]])
    parent2 = BasicTree.new([:call, :*, [:lit, 3], [:lit, 4]])
    offspring = parent1.cross_with(parent2)
    assert_equal [:call, :+, [:lit, 1], [:lit, 4]], offspring.genes
    assert !offspring.genes.equal?(parent1.genes)
    assert !offspring.genes.equal?(parent2.genes)
  end

  def test_crossover_of_function_with_arity_of_zero
    BasicTree.stubs(:rand).returns(0, 0)
    parent1 = BasicTree.new([:call, :+, [:lit, 1], [:lit, 2]])
    parent2 = CustomFunctionsTree.new([:call, :rand])
    offspring = parent1.cross_with(parent2)
    assert_equal [:call, :+, [:lit, 1], [:lit, 2]], offspring.genes
  end

  def test_depth
    assert_equal 0, BasicTree.new([:lit, 1]).depth
    assert_equal 0, CustomFunctionsTree.new([:call, :rand]).depth
    assert_equal 1, BasicTree.new([:call, :*, [:lit, 1], [:lit, 1]]).depth
    assert_equal 2, BasicTree.new([:call, :*, [:call, :+, [:lit, 1], [:lit, 1]], [:lit, 1]]).depth
  end

  def test_equality
    assert_not_equal BasicTree.new([:lit, 1]), BasicTree.new([:lit, 2])
    assert_equal BasicTree.new([:lit, 1]), BasicTree.new([:lit, 1])
  end

  def test_array_membership
    population = [BasicTree.new([:lit, 1]), BasicTree.new([:lit, 1]), BasicTree.new([:lit, 2])]
    assert_equal 3, population.size
    assert_equal 2, population.uniq.size
  end

  class LazyTree < Tree
    attr_accessor :counter

    def initialize(*args)
      @counter = 0
      super
    end

    literals 0..9

    function :lazy_if, :lazy => true do |c,t,f,eval|
      eval[c] ? eval[t] : eval[f]
    end

    function :non_lazy_if, :lazy => false do |c,t,f|
      c ? t : f
    end

    function :inc do |value|
      @counter += value
    end
  end

  def test_lazy_function_calls
    tree = LazyTree.new([:call, :lazy_if, [:lit, true], [:call, :inc, [:lit, 1]], [:call, :inc, [:lit, 2]]])
    tree.evaluate
    assert_equal 1, tree.counter
  end

  def test_non_lazy_function_calls
    tree = LazyTree.new([:call, :non_lazy_if, [:lit, true], [:call, :inc, [:lit, 1]], [:call, :inc, [:lit, 2]]])
    tree.evaluate
    assert_equal 3, tree.counter
  end

  def test_generating_a_function_call_to_a_lazy_function
    RouletteWheel.any_instance.stubs(:rand).returns(0, 0.9, 0.9, 0.9)
    Array.any_instance.stubs(:rand).returns(1, 2, 3)
    LazyTree.stubs(:function_names).returns(stub(:sample => :lazy_if, :empty? => false))
    tree = LazyTree.generate
    assert_equal [:call, :lazy_if, [:lit, 1], [:lit, 2], [:lit, 3]], tree.genes
  end
end