$:.unshift('lib')
require 'genetics'
require "curses"
require "matrix"

module Ant
  attr_accessor :orientation, :position, :food_eaten

  def initialize(*args)
    reset
    super
  end

  def reset
    @orientation = East
    @position = Vector[0,0]
    @food_eaten = 0
  end

  def inspect
    "#<#{self.class.name} @food_eaten=#{food_eaten} @position=#{position} @orientation=#{orientation}>"
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

  def run(trail)
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
    @world = World.new(self, trail, window)
    @world.run
  end

  def fitness
    # TODO: That I have to memoize this points to the fact the I should remove Tree#memoized_fitness.
    @fitness ||= begin
      trail = Trail.santa_fe
      run(trail, false)
      trail.food_count - food_eaten + depth/100.0
    end
  end

  def ideal?
    fitness < 1
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

  def size
    width * height
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
    @visited = Array.new(trail.size, 0)
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

  def visit(position)
    @visited[position[1] * @trail.width + position[0]] = 1
  end

  def visited?(position)
    @visited[position[1] * @trail.width + position[0]] == 1
  end

  def move_ant(move)
    case move
    when :forward
      visit @ant.position
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
    @trail.food_at?(position) && !visited?(position)
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
        elsif visited? position
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
    @window.deleteln
    @window.addstr(@ant.inspect)
    @window.refresh
  end

  EndOfWorld      = Class.new(RuntimeError)
  LunaticAntError = Class.new(RuntimeError)
end

if __FILE__ == $0
  require 'optparse'
  options = { :mode => :run }
  exit_message = nil

  OptionParser.new do |opts|
    opts.on("-i", "--interactive", "Be an ant, explore the trail") { options[:mode] = :interactive }
    opts.on("-e", "--evolve", "Evolve an ant population") { options[:mode] = :evolve }
    opts.on("-d", "--demo", "Same as evolve, but shows the fittest running the trail after each generation") { options[:mode] = :demo }
    opts.on("-r", "--run", "Watch a previously evolved ant run the trail") { options[:mode] = :run }
    opts.on("-g", "--generate", "Watch a randomly generated ant run the trail") { options[:mode] = :generate }
    opts.on("-f", "--for generations", "The number of generations to evolve when using -e or -d") { |n| options[:generations] = n.to_i }
    opts.on("-v", "--verbose", "Show extra detail when evolving a population") { |n| options[:verbose] = true }
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  def with_curses
    include Curses
    init_screen
    start_color
    init_pair(World::ColourPairs::NotVisited, COLOR_WHITE, COLOR_BLACK)
    init_pair(World::ColourPairs::Visited,    COLOR_BLACK, COLOR_YELLOW)
    init_pair(World::ColourPairs::Current,    COLOR_BLACK, COLOR_RED)
    yield
  ensure
    close_screen
  end

  case options[:mode]
  when :interactive
    with_curses do
      ant = InteractiveAnt.new(stdscr)
      food_eaten = ant.run(Trail.santa_fe)
      exit_message = "You ate #{ant.food_eaten} pieces of food!"
    end
  when :evolve, :demo
    population = Population.new(AntBot, :select_with => Tournament, :size => 200)
    generations = options[:generations] || 10
    if options[:mode] == :evolve
      population.evolve(generations) do |p|
        if options[:verbose]
          puts "#{p.generation}: #{p.fittest.fitness}"
        else
          print "."
          $stdout.flush
        end
      end
      print "\n"
    elsif options[:mode] == :demo
      with_curses do
        population.evolve(generations) do |p|
          # It would be cool to show this in a separate thread so evolution can
          # continue in the background.
          p.fittest.reset
          p.fittest.run(Trail.santa_fe, stdscr)
        end
      end
    end
    exit_message = population.fittest.genes.inspect
  when :run
    with_curses do
      # This is a complete, albeit not optimal solution.
      # It took ~2.5 hours to evolve and appeared in the 6787th generation.
      # Here are the main paramaters used:
      # Max tree depth: 4
      # Population size: 200
      # Selection: Tournament (Rounds size: 10)
      # Fitness included a small anti-bloat adjustment.
      # Functions used: food_ahead?, forward, right, left, block.
      # The ant made 400 steps in the world.
      ant = AntBot.new([:call, :block, [:call, :food_ahead?,
        [:call, :block, [:call, :block, [:call, :forward], [:call, :forward]],
        [:call, :food_ahead?, [:call, :food_ahead?, [:call, :block,[:call, :food_ahead?,[:call, :forward], [:call, :right]],
        [:call, :food_ahead?, [:call, :right], [:call, :right]]],
        [:call, :food_ahead?, [:call, :block, [:call, :forward], [:call, :left]], [:call, :food_ahead?, [:call, :left], [:call, :left]]]],
        [:call, :right]]], [:call, :right]],
        [:call, :block, [:call, :block, [:call, :food_ahead?, [:call, :food_ahead?, [:call, :block, [:call, :forward], [:call, :forward]],
        [:call, :block, [:call, :forward], [:call, :forward]]], [:call, :left]], [:call, :left]],
        [:call, :food_ahead?, [:call, :block, [:call, :food_ahead?, [:call, :forward],
        [:call, :block, [:call, :food_ahead?, [:call, :left], [:call, :right]], [:call, :left]]],
        [:call, :food_ahead?, [:call, :forward], [:call, :block, [:call, :food_ahead?, [:call, :left], [:call, :right]],
        [:call, :left]]]], [:call, :block, [:call, :right], [:call, :forward]]]]])
      ant.run(Trail.santa_fe, stdscr)
    end
  when :generate
    with_curses do
      AntBot.generate.run(Trail.santa_fe, stdscr)
    end
  end

  puts exit_message if exit_message
end