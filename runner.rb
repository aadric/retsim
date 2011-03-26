class Runner
  include Singleton
  attr_reader :duration, :current_time, :fights

  # Accepts duration in seconds
  def initialize
    @current_time = 0
    @queue = PriorityQueue.instance
    @queue.clear
    @fights = 200
  end

  def reset
    initialize
  end

  def self.current_time
    self.instance.current_time
  end

  def run(player, mob)
    tick = 0
    i = 0
    start_time = 0
    @fights.times do
      start_time = Runner.current_time
      i += 1
      player.autoattack.use
      while mob.remaining_damage > 0
        unless @queue.empty?
          event = @queue.pop
          
          @current_time = event.time

          event.execute
        end

        unless player.is_gcd_locked 
          yield 
        end
      end

      # Collect some stats
      fight_length = (Runner.current_time - start_time) / 1000
      Statistics.instance.fights << fight_length

      # Reset the fight    
      player.reset
      mob.reset
      @queue.clear
      
      if i > tick
        print "*"
        tick += @fights / 80
      end
    end
    puts ""
  end
end



