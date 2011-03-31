class Runner
  attr_reader :duration, :current_time, :fights, :queue

  # Accepts duration in seconds
  def initialize(sim)
    @sim = sim
    @current_time = 0
    @queue = PriorityQueue.new

    @confidence_level = 1.644854 # 90%
    #@confidence_level = 1.95996 # 95%
    #@confidence_level = 2.32635 # 98%
    @margin_of_error_allowed = 20 # +/- dps

    # Don't use anything less than 98% and +/- 20 DPS for anything serious
  end

  def run
    tick = 0
    i = 0
    start_time = 0
    dpses = []
    going = true

    last_damage = 0
    while going
      start_time = current_time
      i += 1
      @sim.player.autoattack.use
      while @sim.mob.remaining_damage > 0
        unless @queue.empty?
          event = @queue.pop
          
          @current_time = event.time

          event.execute
          end

        unless @sim.player.is_gcd_locked 
          yield 
        end
      end

      this_fights_damage = @sim.stats.total_damage - last_damage
      this_fights_duration = current_time - start_time

      dpses << this_fights_damage / (this_fights_duration / 1000)
      
      last_damage = @sim.stats.total_damage
      last_time = current_time

      if(i % 100 == 0)
        avg_dps = @sim.stats.total_damage / (current_time / 1000)


        standard_deviation = dpses.inject(0) do |sum, item|
          sum += (item - avg_dps) ** 2 
        end

        standard_deviation = (standard_deviation / (dpses.size-1)) ** 0.5
        standard_error = standard_deviation / (dpses.size ** 0.5)
        margin_of_error = standard_error * @confidence_level

        if(margin_of_error <= @margin_of_error_allowed and dpses.size >= 100) 
          going = false
        end

        puts "fights = " + i.to_s
        puts "avg dps " + avg_dps.to_s
        puts "margin_of_error = " + margin_of_error.to_s
      end


      # Collect some stats
      fight_length = (current_time - start_time) / 1000
      @sim.stats.fights << fight_length

      # Reset the fight    
      @sim.player.reset
      @sim.mob.reset
      @queue.clear
    end
  end
end
