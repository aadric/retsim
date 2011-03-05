class Runner
  include Singleton
  attr_reader :duration, :current_time, :fights

  # Accepts duration in seconds
  def initialize
    @current_time = 0
    @queue = PriorityQueue.instance
    @fights = 200
  end

  def self.current_time
    self.instance.current_time
  end

  def run(player, mob)
    tick = 0
    i = 0
    gcds = 0
    @fights.times do
      i += 1
      player.swing
      while mob.remaining_damage > 0
        unless @queue.empty?
          event = @queue.pop
          
          @current_time = event.time

          event.execute
        end

        unless player.is_gcd_locked
          gcds += 1
          yield 
        end
      end
      # Reset the fight    
      player.reset
      mob.reset
      @queue.clear
      
      if i > tick
        print "*"
        tick += @fights / 80
      end
    end
  end
end



