# 1 object of this class = 1 sim
class Simulation
  attr_reader :runner, :mob, :stats, :priorities, :logger, :config_file

  attr_accessor :player, :run_mode, :ignore_hp_for_inq

  # Sim can be run based on a fixed length of time or on the mobs health
  attr_accessor :run_mode # :time, :boss_health
  
  def initialize(opts = {})
    @run_mode = opts[:run_mode] ||= :boss_health
    @config_file = opts[:config_file] ||= "config.txt"

    @runner = Runner.new(self)
    @mob = Mob.new(self)
    @player = Player.new(self)
    @stats = Statistics.new

    @priorities = PriorityWithDelay.new
    @priorities.sim = self # TODO why?

    @logger = Logger.new(self)

    ConfigParser.parse(config_file, self)

    @ignore_hp_for_inq = false

    yield self if block_given?
  end

  def new_event(obj, method_name, interval, identifier = :unknown)
    Event.new(self, obj, method_name, interval, identifier)
  end

  def run
    yield self if block_given?
    @runner.run 
    self
  end
  
  def dps
    @stats.total_damage / (@runner.current_time / 1000)
  end
end
