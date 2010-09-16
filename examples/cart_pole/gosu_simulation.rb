class GosuSimulation < Gosu::Window
  attr_accessor :simulation

  def initialize(controller = nil)
    super(Simulation::WIDTH, Simulation::HEIGHT, false, 16)
    self.caption = "Cart Pole"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @simulation = Simulation.new(controller)
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

  # def control
  #   case @controller.tick(self)
  #   when -1
  #     @cart.thrust :left
  #   when 1
  #     @cart.thrust :right
  #   when 0
  #     @cart.thrust :none
  #   end
  # end

  def update
    poll_keyboard
    @simulation.tick
  end

  def draw
    #@cart.draw
    body = @simulation.cart.body
    pole = @simulation.cart.pole

    draw_rect(body.p.x, body.p.y, Cart::WIDTH, Cart::HEIGHT, Cart::COLOUR)
    rotate((pole.a/Math::PI)*180, pole.p.x, pole.p.y) do
      c = pole.a.abs > 0.21 ? Gosu::Color::RED : Cart::COLOUR
      draw_rect(pole.p.x, pole.p.y, 5, Cart::POLE_LENGTH, c)
    end

    @font.draw("a = #{pole.a}", 10, 10, 0, 1.0, 1.0, Gosu::Color::YELLOW)
    @font.draw("w = #{pole.w}", 10, 30, 0, 1.0, 1.0, Gosu::Color::YELLOW)
    @font.draw("offset = #{@simulation.cart.offset}", 10, 50, 0, 1.0, 1.0, Gosu::Color::YELLOW)
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


# class InteractiveController
#   def tick(simulation)
#     if simulation.button_down? Gosu::KbLeft
#       -1
#     elsif simulation.button_down? Gosu::KbRight
#       1
#     else
#       0
#     end
#   end
# end
# 
# class Screen
#   def init(controller = nil)
#     @controller = controller || InteractiveController.new(self)
#     @simulation = Simulation.new(@controller)
#   end
#   
#   def update
#     
#   end
#   
#   def draw
#     # Do _all_ the drawing.
#   end
# end