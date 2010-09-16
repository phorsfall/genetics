class Simulation
  attr_accessor :ticks, :cart

  WIDTH    = 640
  HEIGHT   = 480
  SUBSTEPS = 6

  def initialize(controller = nil)
    @controller = controller
    @ticks = 0
    @dt = 1.0/60.0
    @space = CP::Space.new
    @space.gravity = CP::Vec2.new(0, 10)
    @static_body = CP::Body.new(Float::MAX, Float::MAX)
    @cart = Cart.new(@space, @static_body)
  end

  def reset
    @cart.reset
  end

  def unbalance(dir = 1)
    #@cart.body.v = CP::Vec2.new(20, 0)
    @cart.pole.apply_impulse CP::Vec2.new(60*dir, 0), CP::ZERO_VEC_2
    @cart.body.v = CP::Vec2.new(10*dir, 0)
    #@cart.pole.a = 0.2
  end

  def poll_controller
    # TODO: Pass only required params.
    # If the controller returns -1, 0, 1 just pass that on to the cart.
    @cart.thrust @controller.tick(self)
    # case @controller.tick(self)
    # when -1
    #   @cart.thrust :left
    # when 1
    #   @cart.thrust :right
    # when 0
    #   @cart.thrust :none
    # end
  end

  def tick
    poll_controller if @controller
    SUBSTEPS.times { @space.step(@dt) }
    @ticks += 1
  end

  def run_while
    tick while yield(self)
  end

  # def run(max_ticks, failure_angle)
  #   while @ticks < max_ticks && @cart.pole.a.abs < failure_angle
  #     update
  #   end
  #   @ticks
  # end
end