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
    @ticks = 0
    @cart.reset
  end

  def unbalance(dir = 1)
    @cart.pole.apply_impulse CP::Vec2.new(150*dir, 0), CP::ZERO_VEC_2
    #@cart.body.v = CP::Vec2.new(10*dir, 0)
  end

  def poll_controller
    @cart.thrust @controller.tick(self)
  end

  def tick
    poll_controller if @controller
    SUBSTEPS.times { @space.step(@dt) }
    @ticks += 1
  end

  def run_while
    tick while yield(self)
  end
end