require 'rubygems'
require 'test/unit'
require 'redgreen'
require 'tree'

class TreeTest < Test::Unit::TestCase
  def test_if_function_wrapper
    assert_equal 1, Function.if.call(0, 0, 1)
    assert_equal 0, Function.if.call(1, 0, 1)
  end

  def test_gt_function_wrapper
    assert_equal 0, Function.gt.call(0, 1)
    assert_equal 1, Function.gt.call(1, 0)
  end
  
  def test_const
    assert_equal 0,  Const.new(0).evaluate
    assert_equal 10, Const.new(10).evaluate(0, 1)
  end
  
  def test_param
    assert_equal 0, Param.new(0).evaluate(0, 1)
    assert_equal 1, Param.new(1).evaluate(0, 1)
  end

  def test_constant_addition
    addition = Node.new(Function.add, Const.new(5), Const.new(20))
    assert_equal 25, addition.evaluate
  end

  def test_param_addition
    addition = Node.new(Function.add, Param.new(0), Param.new(1))
    assert_equal 25, addition.evaluate(5, 20)
  end

  def test_square
    square = Node.new(Function.multiply, Param.new(0), Param.new(0))
    assert_equal 4, square.evaluate(2)
    assert_equal 100, square.evaluate(10)
  end
  
  def test_deeper_tree
    expression = Node.new(
      Function.if, 
        Node.new(
          Function.gt, Param.new(0), Const.new(3)),
            Node.new(Function.add,
              Param.new(1), Const.new(5)),
            Node.new(Function.subtract,
              Param.new(1), Const.new(2)))

    assert_equal 1, expression.evaluate(2, 3)
    assert_equal 8, expression.evaluate(5, 3)
  end
  
  def test_deep_cloning
    expression = Node.new(
      Function.if, 
        Node.new(
          Function.gt, Param.new(0), Const.new(3)),
            Node.new(Function.add,
              Param.new(1), Const.new(5)),
            Node.new(Function.subtract,
              Param.new(1), Const.new(2)))

    clone = expression.clone
    expression.children[0].children[1] = Const.new(100)

    assert_equal 3,   clone.children[0].children[1].value
    assert_equal 100, expression.children[0].children[1].value
  end
end