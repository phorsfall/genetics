class Controller < Tree
  args :angle, :angular_velocity, :position, :velocity
  literals [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  function(:+) { |a,b| a+b }
  function(:-) { |a,b| a-b }
  function(:*) { |a,b| a*b }
  # function(:%) do |a,b|
  #   b.zero? ? 0.0 : a%b
  # end
  function(:abs) { |a| a.abs }

  def tick(s)
    raw_result = evaluate(:angle => s.cart.pole.a,
      :angular_velocity => s.cart.pole.w,
      :position => s.cart.body.p.x,
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
    fitness < 50
  end

  MAX_TICKS = 300

  def fitness
    @fitness ||= begin
      simulation = Simulation.new(self)

      simulation.unbalance
      rms = 0

      simulation.run_while do |s|
        rms += s.cart.offset**2
        s.ticks < MAX_TICKS && s.cart.pole.a.abs < 0.21 && s.cart.offset < 40
      end
      simulation.reset
      simulation.unbalance(-1)
      
      simulation.run_while do |s|
        rms += s.cart.offset**2
        s.ticks < MAX_TICKS && s.cart.pole.a.abs < 0.21 && s.cart.offset < 40
      end


      rms = Math.sqrt(rms)
      #puts "RMS: #{rms}"

      #simulation.show
      # Running ~1000 ticks causes a seg fault, don't know why.
      #6000 - simulation.run(6000, 0.21)
      (MAX_TICKS*2-simulation.ticks)+(rms/10)
    end
  end
end
