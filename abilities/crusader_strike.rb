class CrusaderStrike < Ability

  def use
    return unless usable?
    dmg = @sim.player.weapon_damage(:normalized => true) * 1.35 

    dmg *= @sim.player.physical_bonus_multiplier

    dmg *= 1 - @sim.mob.damage_reduction_from_armor(@sim.player.level)

    dmg *= 1 + (@sim.player.talent_crusade * 0.10) if @sim.player.talent_crusade

    dmg *= 1.2 if @sim.player.two_handed_specialization

    @attack = @sim.player.special_attack_table(:crit_chance => crit_chance)

    dmg *= @sim.player.crit_multiplier(:physical) if @attack == :crit

    @sim.mob.deal_damage(:crusader_strike, @attack, dmg)

    unless [:miss, :dodge].include?(@attack)
      # Hand of Light can't crit and is unaffected by anything that affected
      # the original attack EXCEPT for inquisition.
      hand_of_light_dmg = dmg * @sim.player.mastery_percent
      hand_of_light_dmg *= 1.3 if @sim.player.inquisition.active?

      # It IS affected by 8% debuff on the mob (not double dipping because this doesn't 
      # http://elitistjerks.com/f76/t110342-retribution_concordance_4_0_6_compliant/p35/#post1899490 
      hand_of_light_dmg *= 1.08 if @sim.mob.debuff_spell_damage

      @sim.mob.deal_damage(:hand_of_light, :hit, hand_of_light_dmg)
    end

    # TODO : Do haste procs immediately reduce the cooldown? Should be easy to test with heroism
    cooldown_up_in(cooldown)

    @sim.player.lock_gcd

    increase_holy_power
  end

  # This method gets monkey patched if Zealotry is loaded
  def increase_holy_power
    @sim.player.holy_power +=1 unless @sim.player.holy_power == 3
  end

  def crit_chance
    crit_chance = @sim.player.melee_crit_chance
    crit_chance += 0.05 if @sim.player.glyph_of_crusader_strike
    crit_chance += 0.05 * @sim.player.talent_rule_of_law 
    return crit_chance
  end

  def cooldown
    cooldown = 4.5
    return cooldown unless @sim.player.talent_sanctity_of_battle
    cooldown /= 1 + @sim.player.calculated_haste(:magic) / 100.0 # From Redcape's spreadsheet 5.16
    return cooldown
  end

  def usable?
    return super and !@sim.player.gcd_locked?
  end

end
