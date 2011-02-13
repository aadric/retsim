class Event
  attr_reader :time
  attr_accessor :dead

  def initialize(obj, method_name, time)
    @obj = obj
    @method_name = method_name
    @time = time
    
    PriorityQueue.instance.push(self, time)
  end
  
  def execute
    @obj.send(@method_name, time) unless @dead
  end

end
