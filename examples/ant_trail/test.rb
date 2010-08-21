class Foo
  def initialize(state)
    @some_state = state
  end

  @@bar = lambda { |a| puts @some_state, a }

  def call
    #instance_exec rand, &@@bar
    @@bar.call(rand)
  end
end


f1 = Foo.new("f1")
f2 = Foo.new("f2")

f1.call
f2.call