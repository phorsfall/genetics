module BaseModule
  def speak(text = "blah")
    puts "#{self.class.name} says '#{text}'"
  end
end

module Friendly
  include BaseModule
  def speak
    super("Hello")
  end
end


module Angry
  include BaseModule
  def speak
    super("Get lost")
  end
end

def Speak(options = {})
  Module.new do
    options = options.dup
    
    define_method :speak_options do
      options
    end

    def speak
      puts "I say #{speak_options[:text]}"
    end
  end
end


Friendly2 = Speak(:text => "Hi!")
Angry2    = Speak(:text => "Get lost")



#puts @@text

class Foo
  #include Angry2
  #include Friendly2
  include Speak(:text => "the truth")
end

f = Foo.new

f.speak
puts f.speak_options.inspect
#puts f.instance_eval { @@text }
