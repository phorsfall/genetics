class GosuSimulation < Gosu::Window
  attr_accessor :simulation

  def initialize(controller = nil)
    super(Simulation::WIDTH, Simulation::HEIGHT, false, 16)
    self.caption = "Cart Pole"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @simulation = Simulation.new(controller)
    @current_line = 0
  end

  def poll_keyboard
    if button_down? Gosu::KbLeft
      @simulation.cart.thrust(-1)
    elsif button_down? Gosu::KbRight
      @simulation.cart.thrust(1)
    else
      @simulation.cart.thrust(0)
    end

    if button_down? Gosu::KbO
      @simulation.cart.pole.force = CP::Vec2.new(-500, 0)
    elsif button_down? Gosu::KbP
      @simulation.cart.pole.force = CP::Vec2.new(500, 0)
    else
      @simulation.cart.pole.force = CP::Vec2.new(0, 0)
    end

    @simulation.reset if button_down? Gosu::KbR
  end

  def update
    poll_keyboard
    @simulation.tick
  end

  def draw
    body = @simulation.cart.body
    pole = @simulation.cart.pole

    draw_rect(body.p.x, body.p.y, Cart::WIDTH, Cart::HEIGHT, Cart::COLOUR)
    rotate((pole.a/Math::PI)*180, pole.p.x, pole.p.y) do
      c = pole.a.abs > 0.21 ? Gosu::Color::RED : Cart::COLOUR
      draw_rect(pole.p.x, pole.p.y, 5, Cart::POLE_LENGTH, c)
    end

    puts "r => reset | esc => exit | left,right => push cart | o,p => push pole"
    puts "a = #{pole.a}"
    puts "w = #{pole.w}"
    puts "p = #{@simulation.cart.offset}"
    puts "v = #{body.v.x}"
    puts "f = #{body.f.x}"

    @current_line = 0
  end

  def puts(string)
    @font.draw(string, 10, @current_line*20+5, 0, 1.0, 1.0, Gosu::Color::YELLOW)
    @current_line += 1
  end

  def draw_rect(x, y, h, w, c)
    # Draws a rectangle centered around x, y.
    draw_quad(x-h/2, y-w/2, c, x+h/2, y-w/2, c, x+h/2, y+w/2, c, x-h/2, y+w/2, c)
  end

  def button_down(id)
    case id
    when Gosu::KbEscape
      close
    end
  end
end
