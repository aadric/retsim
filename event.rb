class Event
  attr_reader :time, :indentifier

  def initialize(obj, method_name, interval, identifier = :unknown)
    @obj = obj
    @method_name = method_name
    @time = Runner.current_time + interval * 1000
    @identifier = identifier
    
    PriorityQueue.instance.push(self, time)
  end
  
  def execute
    @obj.send(@method_name) unless @dead
  end

  def kill
    @dead = true
  end

end
