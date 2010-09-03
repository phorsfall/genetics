$:.unshift('lib')
require 'genetics'
require "curses"
require "matrix"

module Ant
  attr_accessor :orientation, :position, :food_eaten

  def initialize(*args)
    @orientation = East
    @position = Vector[0,0]
    @food_eaten = 0
    super
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

  function :food_ahead?, :lazy => true do |t,f,eval|
    @world.uneaten_food_ahead? ? eval[t] : eval[f]
  end

  function :left do
    @world.move_ant(:left)
  end

  function :right do
    @world.move_ant(:right)
  end

  function :forward do
    @world.move_ant(:forward)
  end

  function :block, :lazy => true do |n1, n2, eval|
    eval[n1]
    eval[n2]
  end

  # TODO: Build a measure of efficiency into fitness.
  # i.e. The less steps the ant take the better.
  # AntBot#explore should probably return [food_eaten, steps/ticks].

  def run(trail, window = nil)
    # Have the ant make 400 steps on the trail
    # and count how much food is colllected.
    @world = World.new(self, trail, window)
    @world.run
  end

  def fitness
    # TODO: That I have to memoize this points to the fact the I should remove Tree#memoized_fitness.
    @fitness ||= begin
      trail = Trail.santa_fe
      run(trail, false)
      trail.food_count - food_eaten
    end
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

  def food_count
    @cells.flatten.select { |cell| cell == 1 }.size
  end

  def self.santa_fe
    # TODO: Load from file.
    new([
      [0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0],
      [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0],
      [0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0],
      [0,0,0,1,1,1,1,0,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,1,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
      [0,0,0,1,1,0,0,1,1,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
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
    # TODO: Resolve that the ant gets progressively slower the longer it explores the world.
    # I think this is happens as more points are stored in @path.
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
    return unless @window
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
  require 'optparse'
  mode = :run

  OptionParser.new do |opts|
    opts.on("-i", "--interactive", "Be an ant, explore the trail") do
      mode = :interactive
    end

    opts.on("-e", "--evolve", "Evolve a new ant") do
      mode = :evolve
    end

    opts.on("-r", "--run", "Watch an ant run the trail") do
      mode = :run
    end

    opts.on("-g", "--generate", "Watch a random ant run the trail") do
      mode = :generate
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  include Curses
  init_screen
  start_color
  init_pair(World::ColourPairs::NotVisited, COLOR_WHITE, COLOR_BLACK)
  init_pair(World::ColourPairs::Visited,    COLOR_BLACK, COLOR_YELLOW)
  init_pair(World::ColourPairs::Current,    COLOR_BLACK, COLOR_RED)

  case mode
  when :interactive
    ant = InteractiveAnt.new(stdscr)
    ant.explore(Trail.santa_fe)
  when :evolve
    population = Population.new(AntBot, :select_with => Tournament)
    population.evolve(5) do
      print "."
      $stdout.flush
    end
    winner = population.fittest
    puts winner.genes.inspect
  when :run
    #ant = AntBot.new([:call, :block, [:call, :forward], [:call, :block, [:call, :left], [:call, :block, [:call, :forward], [:call, :right]]]])
    ant = AntBot.new([:call, :block, [:call, :block, [:call, :forward], [:call, :block, [:call, :food_ahead?, [:call, :right], [:call, :left]], [:call, :block, [:call, :block, [:call, :right], [:call, :right]], [:call, :forward]]]], [:call, :food_ahead?, [:call, :block, [:call, :food_ahead?, [:call, :right], [:call, :left]], [:call, :food_ahead?, [:call, :block, [:call, :forward], [:call, :block, [:call, :food_ahead?, [:call, :right], [:call, :right]], [:call, :food_ahead?, [:call, :forward], [:call, :food_ahead?, [:call, :right], [:call, :block, [:call, :forward], [:call, :food_ahead?, [:call, :right], [:call, :block, [:call, :right], [:call, :forward]]]]]]]], [:call, :left]]], [:call, :left]]])
    ant.run(Trail.santa_fe, stdscr)
  when :generate
    AntBot.generate.run(Trail.santa_fe, stdscr)
  # when :demo?
    # Show the ant after each generation?
  end

  close_screen
  # Allow an exit_message to be set?
  #puts "You ate #{ant.food_eaten} pieces of food!"
end