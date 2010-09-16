class Controller < Tree
  args :angle, :angular_velocity, :position, :velocity
  literals (1..10).map { |n| n/10.0 } + [-1.0]
  function(:+) { |a,b| a+b }
  function(:-) { |a,b| a-b }
  function(:*) { |a,b| a*b }

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
      ticks = 0
      simulation.unbalance

      simulation.run_while do |s|
        s.ticks < MAX_TICKS && s.cart.pole.a.abs < 0.21 && s.cart.offset.abs < 40
      end
      ticks += simulation.ticks
      simulation.reset
      simulation.unbalance(-1)
      simulation.run_while do |s|
        s.ticks < MAX_TICKS && s.cart.pole.a.abs < 0.21 && s.cart.offset.abs < 40
      end
      ticks += simulation.ticks
      (MAX_TICKS*2-ticks)
    end
  end
end
