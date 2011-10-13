class Controller < Tree
  args :angle, :angular_velocity, :position, :velocity
  literals ERCG.new
  function(:+) { |a,b| a+b }
  function(:-) { |a,b| a-b }
  function(:*) { |a,b| a*b }
  function(:inv) { |a| -a }

  def tick(s)
    raw_result = evaluate(:angle => s.cart.pole.a,
      :angular_velocity => s.cart.pole.w,
      :position => s.cart.offset,
      :velocity => s.cart.body.v.x)

    if raw_result > 0
      1
    elsif raw_result < 0
      -1
    else
      0
    end
  end

  def ideal?
    fitness.zero?
  end

  MAX_TICKS = 600

  def fitness
    @fitness ||= begin
      simulation = Simulation.new(self)
      test_cases = [0.5, 1.0]
      fitness = [0, 0] # Track fitness in each direction.

      test_cases.each do |t|
        [-1, 1].each do |dir|
          equilibrium_bonus = 0
          simulation.reset
          simulation.unbalance(t*dir)
          simulation.run_while do |s|
            equilibrium_bonus += 1 if s.cart.pole.a.abs < 0.002 && s.cart.body.v.x.abs < 1
            s.ticks < MAX_TICKS && s.cart.pole.a.abs < 0.21 && s.cart.offset.abs < 70
          end
          fitness[dir == -1 ? 0 : 1] += (MAX_TICKS*2-simulation.ticks-equilibrium_bonus)
        end
      end

      #puts fitness.inspect
      # Penalise unbalances solutions by only including the least fit side.
      fitness.max + depth/50.0

      # simulation.unbalance
      #
      # simulation.run_while do |s|
      #   equilibrium_bonus += 1 if s.cart.pole.a.abs < 0.005 && s.cart.body.v.x.abs < 0.4
      #   s.ticks < MAX_TICKS && s.cart.pole.a.abs < 0.21 && s.cart.offset.abs < 120
      # end
      # ticks += simulation.ticks
      # simulation.reset
      # simulation.unbalance(-1)
      # simulation.run_while do |s|
      #   equilibrium_bonus += 1 if s.cart.pole.a.abs < 0.005 && s.cart.body.v.x.abs < 0.4
      #   s.ticks < MAX_TICKS && s.cart.pole.a.abs < 0.21 && s.cart.offset.abs < 120
      # end
      # ticks += simulation.ticks
      # if equilibrium_bonus > 0
      #   puts equilibrium_bonus
      #   puts genes.inspect
      # end

      #(MAX_TICKS*test_cases.size*2-ticks-equilibrium_bonus)
    end
  end
end
