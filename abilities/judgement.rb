class Judgement < Ability

  def use
    # TODO this is all hardcorded for seal of truth
    raise "Judgement still on cooldown" unless usable?

    dmg = @player.calculated_attack_power * 0.1421
    dmg += @player.calculated_spell_power * 0.2229

    dmg *= @player.magic_bonus_multiplier

    dmg *= 1 + (0.1 * @player.seal_of_truth.censure_stacks)

    dmg *= 1.1 if @player.glyph_of_judgement

    dmg *= 1.2 if @player.two_handed_specialization

    @attack = @player.special_attack_table(:crit_chance => crit_chance, :ranged => true)

    dmg *= @player.crit_multiplier(:physical) if @attack == :crit

    @mob.deal_damage(:judgement, @attack, dmg) # TODO compare name of attack to recount

    cooldown_up_in(8)

    @player.lock_gcd
  end

  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.06 * @player.talent_arbiter_of_the_light if @player.talent_arbiter_of_the_light
  end

end
