require 'rubygems'
require 'test/unit'
require 'redgreen'
require 'mocha'
require 'tree'

class TreeTest < Test::Unit::TestCase
  def test_literal
    tree = Tree.new([:lit, 100])
    assert_equal 100, tree.evaluate
  end

  def test_addition
    tree = Tree.new([:call, :+, [:lit, 100], [:lit, 200]])
    assert_equal 300, tree.evaluate
  end

  def test_subtraction
    tree = Tree.new([:call, :-, [:lit, 10], [:lit, 2]])
    assert_equal 8, tree.evaluate
  end

  def test_multiplication
    tree = Tree.new([:call, :*, [:lit, 10], [:lit, 10]])
    assert_equal 100, tree.evaluate
  end

  def test_nested_function_calls
    tree = Tree.new([:call, :*, [:call, :+, [:lit, 2], [:lit, 3]], [:call, :+, [:lit, 4], [:lit, 5]]])
    assert_equal 45, tree.evaluate
  end

  def test_x_arg
    tree = Tree.new([:arg, :x])
    assert_equal 100, tree.evaluate(:x => 100)
  end

  def test_y_arg
    tree = Tree.new([:arg, :y])
    assert_equal 100, tree.evaluate(:y => 100)
  end

  def test_multiplication_with_args
    tree = Tree.new([:call, :*, [:arg, :x], [:arg, :y]])
    assert_equal 27, tree.evaluate(:x => 3, :y => 9)
  end

  def test_generating_a_random_tree
    Tree.stubs(:rand).returns(0, 0, 1, 1, 7, 1, 1, 8)
    tree = Tree.generate
    assert_equal 15, tree.evaluate
  end

  def test_generating_a_random_tree_with_args
    Tree.stubs(:rand).returns(0, 0, 1, 0, 0, 1, 0, 1)
    tree = Tree.generate
    assert_equal 30, tree.evaluate(:x => 10, :y => 20)
  end

  class LiteralsTree < Tree
    literals 40..45
  end

  def test_generating_a_random_with_custom_literals
    LiteralsTree.stubs(:rand).returns(1, 1, 2)
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
end