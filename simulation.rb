# 1 object of this class = 1 sim
class Simulation
  attr_reader :runner, :mob, :stats
  attr_accessor :player

  
  def initialize(config, bonuses, priorities)
    @runner = Runner.new(self)
    @mob = Mob.new(self)
    @player = Player.new(self)
    @stats = Statistics.new

    ConfigParser.parse(config, self)
  end

  def new_event(obj, method_name, interval, identifier = :unknown)
    Event.new(self, obj, method_name, interval, identifier)
  end

  def run
    @runner.run do 
      if player.heroism.usable?
        player.heroism.use
      end
      
      if player.guardian_of_ancient_kings.usable?
        player.guardian_of_ancient_kings.use
      end

      if player.zealotry.usable?
        player.zealotry.use
      end

      # Cast at 6 seconds or less of inquisition if we have full holy power
      if player.has_holy_power(3) and player.inquisition.buff_remaining <= 0
        player.inquisition.use
        next
      end

      unless player.avenging_wrath.on_cooldown?
        player.use_trinkets
        player.avenging_wrath.use
      end

      # Cast Crusader Strike if we dont have 3 HP
      if player.crusader_strike.usable? and player.holy_power < 3
        player.crusader_strike.use
        next
      end
      
      # Cast at 6 seconds or less of inquisition if we have full holy power
      if player.has_holy_power(3) and player.inquisition.buff_remaining < 6
        player.inquisition.use
        next
      end

      # Cast TV if we can
      if player.has_holy_power(3)
        player.use_trinkets
        player.templars_verdict.use
        next
      end

      if player.hammer_of_wrath.usable?
        player.hammer_of_wrath.use
        next
      end

      if player.exorcism.art_of_war_proc?
        player.exorcism.use
        next
      end

      if player.judgement.usable?
        player.judgement.use
        next
      end

      if player.holy_wrath.usable?
        player.holy_wrath.use
        next
      end

      if player.consecration.usable?
        player.consecration.use
        next
      end
    end
  end
end
