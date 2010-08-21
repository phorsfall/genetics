$:.unshift('lib')
require 'genetics'
require "curses"
require "matrix"

class InteractiveAnt
  attr_accessor :orientation, :position, :food_eaten

  def initialize(window)
    @orientation = 1
    @position = Vector[0,0]
    @food_eaten = 0
    @window = window
    @window.keypad = true
  end

  def evaluate
    case @window.getch
    when Curses::KEY_UP
      Ant::Move
    when Curses::KEY_LEFT
      Ant::Left
    when Curses::KEY_RIGHT
      Ant::Right
    end
  end
end

class Ant < Tree
  # x, y => init to 0,0
  # direction => init to east

  Move  = 1
  Left  = 2
  Right = 3
  literals 1..3

  function :food_ahead? do |t,f|
    @world.food_ahead? ? t : f
  end

  # TODO: Add the prog n funcs

  def fitness
    # Have the ant make 400 steps on the trail
    # and count how much food is colllected.
    @world = World.new(self, Trail.santa_fe)
    @world.run
    food_eaten
  end
end

class Trail
  def initialize(cells)
    @cells = cells
  end

  def width
    @cells[0].size
  end

  def height
    @cells.size
  end

  def [](position)
    @cells[position[1]][position[0]]
  end

  def self.santa_fe
    new([
      [0,1,0,0,0,0,0,0,0,0],
      [0,1,0,0,0,0,0,0,0,0],
      [0,0,1,0,0,0,0,0,0,0],
      [0,0,0,1,0,0,0,0,0,0],
      [0,0,0,0,1,0,0,0,0,0],
      [0,0,0,0,1,0,0,0,0,0],
      [0,0,0,0,1,1,1,0,0,0],
      [0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0]
    ])
  end
end

class World
  def initialize(ant, trail, window)
    @ant = ant
    @trail = trail
    @ticks = 0
    @path = []
    @window = window
  end

  def run(ticks = 400)
    ticks.times do
      draw
      tick
    end
  end

  Moves = {
    0 => Vector[0,-1], # N
    1 => Vector[1,0],  # E
    2 => Vector[0,1],  # S
    3 => Vector[-1,0]  # W
  }

  def tick
    @path << @ant.position
    case @ant.evaluate
    when Ant::Move
      @ant.position = next_position
      @ant.food_eaten += 1 if food_at?(@ant.position)
    when Ant::Left
      @ant.orientation -= 1
      @ant.orientation %= 4
    when Ant::Right
      @ant.orientation += 1
      @ant.orientation %= 4
    else raise LunaticAntError
    end
    @ticks += 1
  end

  def next_position
    position = @ant.position + Moves[@ant.orientation]
    # position[0] %= @trail.width
    # position[1] %= @trail.height
    Vector[position[0] % @trail.width, position[1] % @trail.height]
  end

  def food_ahead?
    food_at?(next_position)
  end

  def food_at?(position)
    @trail[position] == 1 && !@path.include?(position)
  end

  Ants = {
    0 => "/\\",
    1 => ">>",
    2 => "\\/",
    3 => "<<"
  }

  def draw
    (0...@trail.width).each do |x|
      (0...@trail.height).each do |y|
        position = Vector[x,y]

        pair = if @ant.position == position
          3 # Current
        elsif @path.include?(position)
          2 # Visited
        else
          1 # Not-visited
        end

        content = if @ant.position == position
          Ants[@ant.orientation]
        elsif @trail[position] == 1
          "()"
        else
          ". "
        end

        @window.setpos(position[1], position[0]*2)
        @window.attron(Curses.color_pair(pair))
        @window.addstr(content)
      end
    end
    @window.attron(Curses.color_pair(1))
    @window.setpos(@trail.height + 2, 0)
    @window.addstr(@ant.inspect)
    @window.refresh
  end

  LunaticAntError = Class.new(RuntimeError)
end

include Curses

init_screen
start_color
init_pair(1, COLOR_WHITE, COLOR_BLACK)
init_pair(2, COLOR_BLACK, COLOR_YELLOW)
init_pair(3, COLOR_BLACK, COLOR_RED)

ant = InteractiveAnt.new(stdscr)
World.new(ant, Trail.santa_fe, stdscr).run

close_screen

puts "You ate #{ant.food_eaten} pieces of food!"