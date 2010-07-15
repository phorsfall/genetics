require 'rubygems'
require 'test/unit'
require 'redgreen'
require 'mocha'
require 'tree'

class TreeTest < Test::Unit::TestCase
  class NoArgsTree < Tree
  end
  
  def test_literal
    tree = NoArgsTree.new([:lit, 100])
    assert_equal 100, tree.evaluate
  end

  def test_addition
    tree = NoArgsTree.new([:call, :+, [:lit, 100], [:lit, 200]])
    assert_equal 300, tree.evaluate
  end

  def test_subtraction
    tree = NoArgsTree.new([:call, :-, [:lit, 10], [:lit, 2]])
    assert_equal 8, tree.evaluate
  end

  def test_multiplication
    tree = NoArgsTree.new([:call, :*, [:lit, 10], [:lit, 10]])
    assert_equal 100, tree.evaluate
  end

  class SingleArgTree < Tree
    arg :x
  end

  def test_single_arg
    tree = SingleArgTree.new([:arg, :x])
    assert_equal 100, tree.evaluate(:x => 100)
  end

  class XYTree < Tree
    args :x, :y
  end

  def test_multiple_args
    tree = XYTree.new([:arg, :y])
    assert_equal 200, tree.evaluate(:x => 100, :y => 200)
  end

  def test_multiplication_with_args
    tree = XYTree.new([:call, :*, [:arg, :x], [:arg, :y]])
    assert_equal 27, tree.evaluate(:x => 3, :y => 9)
  end

  def test_nested_function_calls
    tree = NoArgsTree.new([:call, :*, [:call, :+, [:lit, 2], [:lit, 3]], [:call, :+, [:lit, 4], [:lit, 5]]])
    assert_equal 45, tree.evaluate
  end

  def test_generating_a_random_tree
    NoArgsTree.stubs(:rand).returns(0, 0, 1, 1, 7, 1, 1, 8)
    tree = NoArgsTree.generate
    assert_equal 15, tree.evaluate
  end

  def test_generating_a_random_tree_with_args
    XYTree.stubs(:rand).returns(0, 0, 1, 0, 0, 1, 0, 1)
    tree = XYTree.generate
    assert_equal 30, tree.evaluate(:x => 10, :y => 20)
  end
end