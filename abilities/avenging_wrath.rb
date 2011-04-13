class AvengingWrath < Ability
  
  def initialize(sim)
    super(sim)
    @sim.player.extend(AugmentMultipliers)
  end

  def use
    return unless usable?
    cooldown = 3 * 60 # 3 minutes

    cooldown -= 20 * @sim.player.talent_sanctified_wrath if @sim.player.talent_sanctified_wrath # Less 20 seconds per point in talent

    cooldown_up_in(cooldown)

    buff_expires_in(20)

    @sim.mob.deal_damage(:avenging_wrath, :hit, 0) # Just to count them 
    # Avenging Wrath is off the GCD
  end

  module AugmentMultipliers
    def magic_bonus_multiplier(magic_type = :holy)
      multiplier = super(magic_type)
      multiplier *= 1.2 if @avenging_wrath.active?
      multiplier
    end

    def physical_bonus_multiplier
      multiplier = super
      multiplier *= 1.2 if @avenging_wrath.active?
      multiplier
    end
  end
end
