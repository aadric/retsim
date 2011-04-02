# 1 object of this class = 1 sim
class Simulation
  attr_reader :runner, :mob, :stats, :priorities
  attr_accessor :player

  
  def initialize(config, bonuses, priorities)
    @runner = Runner.new(self)
    @mob = Mob.new(self)
    @player = Player.new(self, bonuses)
    @stats = Statistics.new
    
    priorities.sim = self
    @priorities = priorities

    ConfigParser.parse(config, self)
  end

  def new_event(obj, method_name, interval, identifier = :unknown)
    Event.new(self, obj, method_name, interval, identifier)
  end

  def run
    @runner.run 
    self
  end
  
  def dps
    @stats.total_damage / (@runner.current_time / 1000)
  end
end
