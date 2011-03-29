class Runner
  include Singleton
  attr_reader :duration, :current_time, :fights

  # Accepts duration in seconds
  def initialize
    @current_time = 0
    @queue = PriorityQueue.instance
    @queue.clear

    #@confidence_level = 1.644854 # 90%
    @confidence_level = 1.95996 # 95%
    #@confidence_level = 2.32635 # 98%
    @margin_of_error_allowed = 10 # +/- dps
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
    dpses = []
    going = true

    last_damage = 0
    while going
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

      avg_dps = Statistics.instance.total_damage / (Runner.current_time / 1000)

      this_fights_damage = Statistics.instance.total_damage - last_damage
      this_fights_duration = Runner.current_time - start_time

      dpses << this_fights_damage / (this_fights_duration / 1000)
      
      last_damage = Statistics.instance.total_damage
      last_time = Runner.current_time

      standard_deviation = dpses.inject(0) do |sum, item|
        sum += (item - avg_dps) ** 2 
      end
      standard_deviation = (standard_deviation / (dpses.size-1)) ** 0.5
      standard_error = standard_deviation / (dpses.size ** 0.5)
      margin_of_error = standard_error * @confidence_level

      if(margin_of_error <= @margin_of_error_allowed and dpses.size >= 100) 
        #puts "fights = " + i.to_s
        #puts "avg dps " + avg_dps.to_s
        #puts "margin_of_error = " + margin_of_error.to_s

        going = false
      end


      # Collect some stats
      fight_length = (Runner.current_time - start_time) / 1000
      Statistics.instance.fights << fight_length

      # Reset the fight    
      player.reset
      mob.reset
      @queue.clear
    end
  end
end



