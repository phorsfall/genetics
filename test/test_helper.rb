require 'rubygems'
require 'test/unit'
begin
  require 'redgreen'
rescue LoadError
end
require 'genetics'
require 'mocha'

class BasicTree < Tree
  args :x, :y
  literals 0..9
  function(:+) { |a,b| a + b }
  function(:*) { |a,b| a * b }
  function(:-) { |a,b| a - b }

  def fitness
    0
  end
end

class SquareTree < Tree
  arg :x
  literals 0..9
  function(:+) { |a,b| a + b }
  function(:*) { |a,b| a * b }
  function(:-) { |a,b| a - b }

  DATA = { 1 => 1, 2 => 4, 3 => 9, 4 => 16, 5 => 25, 6 => 36 }

  def fitness
    @fitness ||= begin
      d = 0
      self.class::DATA.each do |x, expected|
        d += (expected - evaluate(:x => x)).abs
      end
      d
    end
  end

  def ideal?
    fitness.zero?
  end
end

class Player < Tree
  arg :x

  def vs(other)
    Array.new(2) { rand(2) }
  end
end