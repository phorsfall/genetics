class Cart
  attr_accessor :body, :pole

  WIDTH, HEIGHT = 100, 10
  COLOUR = Gosu::Color::GRAY
  THRUST = 1500
  POLE_LENGTH = 300

  def initialize(space, static_body)
    @space = space
    @static_body = static_body

    @body = CP::Body.new(100, 1)
    @body.p = CP::Vec2.new(Simulation::WIDTH/2, Simulation::HEIGHT-100)
    @space.add_body(@body)
    joint = CP::Constraint::GrooveJoint.new(@static_body, @body, CP::Vec2.new(WIDTH, Simulation::HEIGHT-100), CP::Vec2.new(Simulation::WIDTH-WIDTH, Simulation::HEIGHT-100), CP::Vec2.new(0, 0))
    @space.add_constraint(joint)
    @pole = CP::Body.new(20, 10)
    @pole.p = CP::Vec2.new(Simulation::WIDTH/2, Simulation::HEIGHT-100-(POLE_LENGTH/2))
    @space.add_body(@pole)

    # A joint that sets the center of the pole a fixed distance from the center of the cart.
    j1 = CP::Constraint::PinJoint.new(@pole, @body, CP::ZERO_VEC_2, CP::ZERO_VEC_2)
    @space.add_constraint(j1)

    # A joint the pins one end of the pole to the cart.
    j2 = CP::Constraint::PinJoint.new(@pole, @body, CP::Vec2.new(0, -(POLE_LENGTH/2)), CP::ZERO_VEC_2)
    @space.add_constraint(j2)
  end

  def reset
    @body.p = CP::Vec2.new(Simulation::WIDTH/2, Simulation::HEIGHT-100)
    @pole.p = CP::Vec2.new(Simulation::WIDTH/2, Simulation::HEIGHT-100-(POLE_LENGTH/2))
    @body.v = CP::ZERO_VEC_2
    @body.force = CP::ZERO_VEC_2
    @pole.a = 0
    @pole.w = 0
    @pole.v = CP::ZERO_VEC_2
    @pole.force = CP::ZERO_VEC_2
  end

  def thrust(direction)
    @body.force = CP::Vec2.new(THRUST*direction, 0)
  end

  def offset
    Simulation::WIDTH/2 - @body.p.x
  end
end