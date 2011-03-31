class Event
  attr_reader :time, :indentifier

  def initialize(sim, obj, method_name, interval, identifier)
    @obj = obj
    @method_name = method_name
    @time = sim.runner.current_time + interval * 1000
    @identifier = identifier
    
    sim.runner.queue.push(self, time)
  end
  
  def execute
    @obj.send(@method_name) unless @dead
  end

  def kill
    @dead = true
  end

end
