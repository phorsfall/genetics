require 'rubygems'
require 'test/unit'
require 'redgreen'
require 'tree'

class TreeTest < Test::Unit::TestCase
  def test_literal
    tree = Tree.new([:lit, 100])
    assert_equal 100, tree.evaluate
  end

  def test_single_arg
    tree = Tree.new([:arg, 0])
    assert_equal 100, tree.evaluate(100)
  end

  def test_multiple_args
    tree = Tree.new([:arg, 1])
    assert_equal 200, tree.evaluate(100, 200)
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

  def test_multiplication_with_args
    tree = Tree.new([:call, :*, [:arg, 0], [:arg, 1]])
    assert_equal 27, tree.evaluate(3, 9)
  end

  def test_nested_function_calls
    tree = Tree.new([:call, :*, [:call, :+, [:lit, 2], [:lit, 3]], [:call, :+, [:lit, 4], [:lit, 5]]])
    assert_equal 45, tree.evaluate
  end

  def test_named_args
    tree = Tree.new([:arg, :x])
    assert_equal 100, tree.evaluate(:x => 100)
  end
end