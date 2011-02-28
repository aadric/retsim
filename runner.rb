class Runner
  include Singleton
  attr_reader :duration, :current_time

  # Accepts duration in seconds
  def initialize
    @current_time = 0
    @queue = PriorityQueue.instance
    @duration = 10 * 60 * 60 * 1000
  end

  def self.current_time
    self.instance.current_time
  end

  def run(player)
    tick = 0
    while @current_time < @duration
      unless @queue.empty?
        event = @queue.pop
        
        @current_time = event.time
        
        if @current_time > tick
          print "*"
          tick += duration / 80
        end

        event.execute
      end

      unless player.is_gcd_locked
        yield 
      end
    end
  end
end



