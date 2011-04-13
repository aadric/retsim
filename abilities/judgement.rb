class Judgement < Ability

  def use
    # TODO this is all hardcorded for seal of truth
    return unless usable?

    dmg = @sim.player.calculated_attack_power * 0.1421
    dmg += @sim.player.calculated_spell_power * 0.2229

    dmg *= @sim.player.magic_bonus_multiplier

    dmg *= 1 + (0.1 * @sim.player.seal_of_truth.censure_stacks)

    dmg *= 1.1 if @sim.player.glyph_of_judgement

    dmg *= 1.2 if @sim.player.two_handed_specialization

    @attack = @sim.player.special_attack_table(:crit_chance => crit_chance, :ranged => true)

    dmg *= @sim.player.crit_multiplier(:physical) if @attack == :crit

    @sim.mob.deal_damage(:judgement, @attack, dmg) # TODO compare name of attack to recount

    cooldown_up_in(8)

    @sim.player.lock_gcd
  end

  def crit_chance
    crit_chance = @sim.player.melee_crit_chance
    crit_chance += 0.06 * @sim.player.talent_arbiter_of_the_light
  end

  def usable?
    super and !@sim.player.gcd_locked?
  end
end
