class Runner
  FIGHT_LENGTH = 330
  attr_reader :duration, :current_time, :fights, :queue, :start_time, :margin_of_error

  class Pair
    attr_accessor :time, :event
  end

  # Accepts duration in seconds
  def initialize(sim)
    @sim = sim
    @current_time = 0
    @queue = PriorityQueue.new

    #@confidence_level = 1.644854 # 90%
    @confidence_level = 1.95996 # 95%
    #@confidence_level = 2.32635 # 98%
    @margin_of_error_allowed = 20 # +/- dps

    @percent_error_allowed = 0.005 # +/-

    # Don't use anything less than 98% and +/- 20 DPS for anything serious

    @fights = []
    @last_damage = 0
  end

  def fight_length
    Runner::FIGHT_LENGTH
  end

  def inspect_queue(event)
    puts "="*80
    puts "just did " + event.obj.class.to_s + " - " + event.method_name
    events = []
    @queue.each do |key, val|
      obj = Pair.new
      obj.time = key
      obj.event = val
      events << obj
    end

    events.sort! do |obj1, obj2|
      obj1.time <=> obj2.time
    end
    
    puts "current_time = " + current_time.to_s
    events.each do |obj|
      puts obj.time.to_s + " => " + obj.event.obj.class.to_s + " - " + obj.event.method_name
    end

    # wait for user input
    gets
  end

  def time_left
    raise "useless unless run_mode == :time" unless @sim.run_mode == :time

    fight_length - (current_time - @start_time) / 1000.0
  end

  def run(opts = {})
    run_count = opts[:count] ||= 50
    tick = 0
    i = 0
    going = true

    while going
      @start_time = current_time
      i += 1

      @sim.logger.enabled = false

      @sim.player.autoattack.use
      @sim.priorities.execute # I should probably judge here

      duration = random(fight_length-20, fight_length+20)

      if @sim.run_mode == :time
        while (current_time - @start_time) / 1000.0 <= duration
          unless @queue.empty?
            event = @queue.pop
            
            @current_time = event.time

            event.execute
          end

          unless @sim.player.gcd_locked?
            ability_used = @sim.priorities.execute
          end
        end
      else
        while @sim.mob.remaining_damage > 0
          unless @queue.empty?
            event = @queue.pop
            
            @current_time = event.time

            event.execute
          end

          unless @sim.player.gcd_locked?
            ability_used = @sim.priorities.execute
          end

          #inspect_queue(event)
        end
      end

      this_fights_damage = @sim.stats.total_damage - @last_damage
      this_fights_duration = current_time - @start_time

      @fights << this_fights_damage / (this_fights_duration / 1000.0)
      
      @last_damage = @sim.stats.total_damage

      if(i % run_count == 0)
        avg_dps = @sim.stats.total_damage / (current_time / 1000.0)


        standard_deviation = @fights.inject(0) do |sum, item|
          sum += (item - avg_dps) ** 2 
        end

        standard_deviation = (standard_deviation / (@fights.size-1)) ** 0.5
        standard_error = standard_deviation / (@fights.size ** 0.5)
        @margin_of_error = standard_error * @confidence_level

        if(margin_of_error <= @margin_of_error_allowed) 
          going = false
        end
        #if(margin_of_error <= avg_dps * @percent_error_allowed)
          #going = false
        #end
        #going = false
       
        if false
          puts "fights = " + @fights.count.to_s
          puts "avg dps " + avg_dps.round.to_s
          #puts "std dev " + standard_deviation.round_to(2).to_s
          #puts "std_err " + standard_error.round_to(2).to_s
          puts "margin_of_error = " + @margin_of_error.round_to(2).to_s
        end
      end


      # Collect some stats
      fight_length = (current_time - @start_time) / 1000.0
      @sim.stats.fights << fight_length

      # Reset the fight    
      @sim.player.reset
      @sim.mob.reset
      @queue.clear
    end
  end
end
