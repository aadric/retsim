class HolyWrath < Ability

  def initialize(sim)
    super(sim)
  end

  def use
    raise "Error" unless usable?

    dmg = 2402 # TODO confirm
    dmg += 0.61 * @sim.player.calculated_spell_power

    dmg *= @sim.player.magic_bonus_multiplier

    attack = @sim.player.spell_table
    dmg *= @sim.player.crit_multiplier(:magic) if attack == :crit

    @sim.mob.deal_damage(:holy_wrath, attack, dmg)

    @sim.player.lock_gcd(:hasted => true)

    cooldown_up_in(15)
  end
end
