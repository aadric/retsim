class Event
  attr_reader :time, :indentifier
  attr_accessor :dead

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

end
