class Event
  attr_reader :time, :indentifier

  def initialize(obj, method_name, time, identifier = :unknown)
    @obj = obj
    @method_name = method_name
    @time = time
    @identifier = identifier
    
    PriorityQueue.instance.push(self, time)
  end
  
  def execute
    @obj.send(@method_name, time) unless @dead
  end

  def kill
    @dead = true
  end

end
