class Inquisition < Ability

  def initialize(sim)
    super(sim)
    @sim.player.extend(InquisitionBonus)
  end

  def use
    raise "Error" unless usable?

    if @sim.player.divine_purpose.active?
      @sim.player.divine_purpose.clear_buff
      duration = 12
    else
      duration = 4 * @sim.player.holy_power
      @sim.player.holy_power = 0
    end
    duration += 4 if @sim.player.set_bonus_t11_four_piece 

    duration *= 1 + 0.5 * @sim.player.talent_inquiry_of_faith

    buff_expires_in(duration) 

    @sim.mob.deal_damage(:inquisition, :hit, 0) # Just to count them 
    @sim.player.lock_gcd(:hasted => true)
  end

  def usable?
    @sim.player.has_holy_power and super
  end

  module InquisitionBonus
    def magic_bonus_multiplier(magic_type = :holy)
      bonus = super(magic_type)
      bonus *= 1.3 if @inquisition.active? and magic_type == :holy
      bonus
    end
  end
end
