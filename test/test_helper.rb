require 'rubygems'
require 'test/unit'
require 'redgreen'
require 'genetics'
require 'mocha'

class SquareTree < Tree
  arg :x

  DATA = { 1 => 1, 2 => 4, 3 => 9, 4 => 16, 5 => 25, 6 => 36 }

  def fitness
    d = 0
    self.class::DATA.each do |x, expected|
      d += (expected - evaluate(:x => x)).abs
    end
    d
  end

  def ideal?
    fitness.zero?
  end
end