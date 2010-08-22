$:.unshift('lib')
require 'genetics'
require "curses"
require "matrix"

module Ant
  attr_accessor :orientation, :position, :food_eaten

  def initialize
    @orientation = East
    @position = Vector[0,0]
    @food_eaten = 0
  end

  North = 0
  East  = 1
  South = 2
  West  = 3
end

class InteractiveAnt
  include Ant

  def initialize(window)
    super()
    @window = window
    @window.keypad = true
  end

  def explore(trail)
    @world = World.new(self, trail, @window)
    @world.run
  end

  def evaluate
    case @window.getch
    when Curses::KEY_UP
      @world.move_ant(:forward)
    when Curses::KEY_LEFT
      @world.move_ant(:left)
    when Curses::KEY_RIGHT
      @world.move_ant(:right)
    when ?q
      raise World::EndOfWorld
    end
  end
end

class AntBot < Tree
  include Ant

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
    # TODO: Normalize fitness.
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

  def food_at?(position)
    self[position] == 1
  end

  def self.santa_fe
    # TODO: Add a 32x32 grid.
    # TODO: Load from file.
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
  def initialize(ant, trail, window, max_ticks = 400)
    @ant = ant
    @trail = trail
    @ticks = 0
    @path = []
    @window = window
    @max_ticks = max_ticks
  end

  def run
    draw
    # Ideally, we'd just call evaluate here while @ticks < MAX_TICKS.
    # But because the ant can make more than one move within evaluate
    # she may well make a few moves more than MAX_TICKS before we next
    # check the termination condition.
    # Instead we raise an exception in World#move_ant as soon as the tick
    # limit is reached and rescue it here. It's a GOTO, but it works.
    loop { @ant.evaluate }
  rescue EndOfWorld
  end

  def move_ant(move)
    @path << @ant.position
    case move
    when :forward
      @ant.position = next_position
      @ant.food_eaten += 1 if uneaten_food_at?(@ant.position)
    when :left
      @ant.orientation -= 1
      @ant.orientation %= 4
    when :right
      @ant.orientation += 1
      @ant.orientation %= 4
    else raise LunaticAntError
    end
    @ticks += 1
    raise EndOfWorld if @ticks >= @max_ticks
    draw
  end

  Moves = {
    Ant::North => Vector[0,-1],
    Ant::East  => Vector[1, 0],
    Ant::South => Vector[0, 1],
    Ant::West  => Vector[-1,0]
  }

  def next_position
    position = @ant.position + Moves[@ant.orientation]
    # TODO: Roll a Position class that does vector addition and allow this to work:
    # position[0] %= @trail.width
    # position[1] %= @trail.height
    Vector[position[0] % @trail.width, position[1] % @trail.height]
  end

  def uneaten_food_ahead?
    uneaten_food_at?(next_position)
  end

  def uneaten_food_at?(position)
    @trail.food_at?(position ) && !@path.include?(position)
  end

  Ants = {
    0 => "/\\",
    1 => ">>",
    2 => "\\/",
    3 => "<<"
  }

  module ColourPairs
    NotVisited = 1
    Visited    = 2
    Current    = 3
  end

  def draw
    (0...@trail.width).each do |x|
      (0...@trail.height).each do |y|
        position = Vector[x,y]

        pair = if @ant.position == position
          ColourPairs::Current
        elsif @path.include?(position)
          ColourPairs::Visited
        else
          ColourPairs::NotVisited 
        end

        content = if @ant.position == position
          Ants[@ant.orientation]
        elsif @trail.food_at?(position)
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

  EndOfWorld      = Class.new(RuntimeError)
  LunaticAntError = Class.new(RuntimeError)
end

if __FILE__ == $0
  include Curses

  init_screen
  start_color
  init_pair(World::ColourPairs::NotVisited, COLOR_WHITE, COLOR_BLACK)
  init_pair(World::ColourPairs::Visited,    COLOR_BLACK, COLOR_YELLOW)
  init_pair(World::ColourPairs::Current,    COLOR_BLACK, COLOR_RED)

  ant = InteractiveAnt.new(stdscr)
  ant.explore(Trail.santa_fe)

  close_screen
  puts "You ate #{ant.food_eaten} pieces of food!"
end