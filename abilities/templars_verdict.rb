class TemplarsVerdict < Ability

  def use
    raise "No Holy Power for Templar's Verdict" unless usable?

    if @sim.player.divine_purpose.active?
      modifier = 2.35
    else
      case @sim.player.holy_power
        when 1 then modifier = 0.30
        when 2 then modifier = 0.90
        when 3 then modifier = 2.35
      end
    end

    dmg = @sim.player.weapon_damage * modifier

    dmg *= @sim.player.physical_bonus_multiplier
    dmg *= 1 - @sim.mob.damage_reduction_from_armor(@sim.player.level)

    # TODO confirm these are additive
    modifier = 1
    modifier += 0.15 if @sim.player.glyph_of_templars_verdict
    modifier += @sim.player.talent_crusade * 0.10 if @sim.player.talent_crusade
    modifier += 0.10 if @sim.player.set_bonus_t11_two_piece

    dmg *= modifier

    dmg *= 1.2 if @sim.player.two_handed_specialization

    @attack = @sim.player.special_attack_table(:crit_chance => crit_chance)
    dmg *= @sim.player.crit_multiplier(:physical) if @attack == :crit

    @sim.mob.deal_damage(:templars_verdict, @attack, dmg.round)

    unless [:miss, :dodge].include?(@attack)
      hand_of_light_dmg = dmg * @sim.player.mastery_percent
      hand_of_light_dmg *= 1.3 if @sim.player.inquisition.active?
      hand_of_light_dmg *= 1.08 if @sim.mob.debuff_spell_damage

      @sim.mob.deal_damage(:hand_of_light, :hit, hand_of_light_dmg)
    end

    # We keep our holy power on a dodge or a miss
    unless [:miss, :dodge].include?(@attack)
      if @sim.player.divine_purpose.active?
        @sim.player.divine_purpose.clear_buff
      else
        @sim.player.holy_power = 0
      end
    end

    @sim.player.lock_gcd
  end

  def crit_chance
    crit_chance = @sim.player.melee_crit_chance
    crit_chance += 0.06 * @sim.player.talent_arbiter_of_the_light 
    crit_chance
  end

  def usable?
    @sim.player.has_holy_power
  end
end
