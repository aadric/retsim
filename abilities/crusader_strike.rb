class CrusaderStrike < Ability

  def use
    dmg = @player.weapon_damage(:normalized => true) * 1.35 

    dmg *= @player.physical_bonus_multiplier

    dmg *= 1 - @mob.damage_reduction_from_armor(@player.level)

    dmg *= 1 + (@player.talent_crusade * 0.10) if @player.talent_crusade

    dmg *= 1.2 if @player.two_handed_specialization

    @attack = @player.special_attack_table(:crit_chance => crit_chance)

    dmg *= @player.crit_multiplier(:physical) if @attack == :crit

    @mob.deal_damage(:crusader_strike, @attack, dmg)

    hand_of_light_dmg = dmg * @player.mastery_percent
    hand_of_light_dmg * 1.3 if @player.inquisition.active?

    # TODO avenging wrath?
    # can it crit?
    @mob.deal_damage(:hand_of_light, :hit, hand_of_light_dmg)

    cooldown_up_in(cooldown)

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", 1.5)

    increase_holy_power
  end

  # This method gets monkey patched if Zealotry is loaded
  def increase_holy_power
    @player.holy_power +=1 unless @player.holy_power == 3
  end

  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.05 if @player.glyph_of_crusader_strike
    crit_chance += 0.05 * @player.talent_rule_of_law if @player.talent_rule_of_law
    return crit_chance
  end

  def cooldown
    cooldown = 4.5
    return cooldown unless @player.talent_sanctity_of_battle
    cooldown /= 1 + @player.calculated_haste(:magic) / 100
    return cooldown
  end

end
