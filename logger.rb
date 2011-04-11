class Logger
  attr_accessor :enabled

  def initialize(sim)
    @sim = sim
    @enabled = true

    @sim.player.abilities.each do |ability|
      ability.extend(UseWithLogging)
    end

    File.open("battle_log.txt", 'w') do |f|
      f.puts "Battle Log"
    end
  end

  def log(ability)
    return unless enabled
    File.open("battle_log.txt", 'a') do |f|
      time = @sim.runner.current_time
      time = [time/60/1000, time/1000%60,time%1000].map{|t| t.to_s.rjust(2,'0') }.join(":")
      f.puts time + " - " + ability + " - " + @sim.player.holy_power.to_s + "hp"
    end
  end

  module UseWithLogging
    def use
      super
      @sim.logger.log(self.class.to_s)
    end
  end


end
