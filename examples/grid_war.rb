require '../tree'
require '../population'
require 'pp'
require 'ostruct'

class GridWarTree < Tree
  args :x1, :y1, :x2, :y2, :last_move

  function :if do |c,t,f|
    c > 0 ? t : f
  end

  function :gt do |a,b|
    a > b ? 1 : 0
  end

  def fight(competitor)
    {
      1 => :win,
      2 => :loose,
      0 => :draw
    }[GridWar.new(self, competitor).play]
  end
end

class GridWar
  class Position < Struct.new(:x, :y)
  end

  def initialize(player1, player2)
    @board_size = 4
    @players = []

    @player1 = OpenStruct.new(
      :uid => 1,
      :brain => player1,
      :last_move => -1,
      :location => Position.new(rand(@board_size), rand(@board_size)),
      :opponent => nil
    )

    @player2 = OpenStruct.new(
      :uid => 2,
      :brain => player2,
      :last_move => -1,
      :location => Position.new((@player1.location.x + 2) % @board_size, (@player1.location.y + 2) % @board_size),
      :opponent => @player1
    )

    @players << @player1 << @player2
    @player1.opponent = @player2
  end

  def play
    50.times do
      @players.each do |p|
        draw if p.brain.is_a?(InteractivePlayer)
        move = p.brain.evaluate(
          :x1 => p.location.x, :y1 => p.location.y,
          :x2 => p.opponent.location.x, :y2 => p.opponent.location.y,
          :last_move => p.last_move) % 4

        # Lose if you make the same move twice.
        return p.opponent.uid if move == p.last_move
        p.last_move = move

        case move
        when 0
          p.location.x -= 1 unless p.location.x.zero?
        when 1
          p.location.x += 1 unless p.location.x == @board_size-1
        when 2
          p.location.y -= 1 unless p.location.y.zero?
        when 3
          p.location.y += 1 unless p.location.y == @board_size-1
        end

        # Win if you capture your opponent.
        return p.uid if p.location == p.opponent.location
      end
    end
    0 # Game drawn.
  end

  def clear_screen
    system("clear")
  end

  def draw
    clear_screen
    (0...@board_size).each do |y|
      (0...@board_size).each do |x|
        square = "| "
        @players.each do |p|
          square << p.uid.to_s if p.location.x == x && p.location.y == y
        end
        print square.ljust(4)
      end
      print "|\n"
    end
    print "\n"
  end

  class InteractivePlayer
    def initialize(name)
      @name = name
    end

    def evaluate(args)
      puts "#{@name}'s turn."
      puts "Use 2, 4, 6, 8 to move.\n\n"
      {"4" => 0, "6" => 1, "8" => 2, "2" => 3}[gets.chomp]
    end
  end
end

# Evolve a new player:
#population = Population.new(GridWarTree, Tournament)
#winner = population.evolve
#pp winner.genes

# Play against a previously evolved playe.
require 'yaml'
p1 = GridWar::InteractivePlayer.new("Human")
p2 = GridWarTree.new(YAML.load_file("grid_war_genes.yml"))
GridWar.new(p1, p2).play
