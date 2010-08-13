require 'rubygems'
require 'test/unit'
begin
  require 'redgreen'
rescue LoadError
end
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

class Player < Tree
  def vs(other)
    Array.new(2) { rand(2) }
  end
end