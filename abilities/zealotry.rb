class Zealotry < Ability

  def initialize(sim)
    super(sim)

    @sim.player.crusader_strike.extend(ZealotryCheck)
  end

  def use
    raise "Error" unless usable?

    cooldown_up_in(2 * 60)

    buff_expires_in(20)

    # Zealotry is off the GCD
  end

  def usable?
    super(:on_gcd => false) and @sim.player.has_holy_power(3)
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
