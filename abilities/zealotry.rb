class Zealotry < Ability

  def initialize(sim)
    super(sim)

    @sim.player.crusader_strike.extend(ZealotryCheck)
  end

  def use
    raise "Can't use Zealotry yet" unless usable?

    cooldown_up_in(2 * 60)

    buff_expires_in(20)

    # Zealotry is off the GCD
  end

  def useable?
    super and @sim.player.has_holy_power(3)
  end

  module ZealotryCheck
    def increase_holy_power
      if @sim.player.zealotry.active?
        # TODO log statistics
        @sim.player.holy_power = 3 
      else
        super
      end
    end
  end

end  
