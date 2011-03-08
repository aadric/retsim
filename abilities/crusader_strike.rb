class CrusaderStrike
  attr_accessor :on_cooldown

  def initialize(player, mob)
    @mob = mob
    @player = player
    @on_cooldown = false

    @count = 0
    @dmg = 0
  end

  def use
    dmg = @player.weapon_damage(:normalized => true) * 1.35 

#    @count += 1
#    @dmg += dmg
#    puts (@dmg / @count) if @count % 100 == 0

    dmg *= @player.physical_bonus_multiplier

    dmg *= 1 - @mob.damage_reduction_from_armor(@player.level)

    dmg *= 1 + (@player.talent_crusade * 0.10) if @player.talent_crusade
    dmg *= 1.2

    attack = @player.special_attack_table(:crit_chance => crit_chance)

    @last_attack = attack # Keep this floating around for procs

    case attack
      when :crit then dmg *= @player.crit_multiplier(:physical)
      when :miss then dmg = 0
      when :dodge then dmg = 0
    end

    @mob.deal_damage(:crusader_strike, attack, dmg.round)

    hand_of_light_dmg = dmg * @player.mastery_percent
    hand_of_light_dmg * 1.3 if @player.inquisition
    # TODO avenging wrath?
    # can it crit?
    @mob.deal_damage(:hand_of_light, :hit, hand_of_light_dmg)



    @cooldown_obj = Event.new(self, "off_cooldown", cooldown_if_cast_now, :crusader_strike)
    @on_cooldown = true

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", 1.5)

    increase_holy_power
  end

  # This method gets monkey patched if Zealotry is loaded
  def increase_holy_power
    @player.holy_power +=1 unless @player.holy_power == 3
  end

  def reset
    @on_cooldown = false
    @cooldown_obj = nil
  end

  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.05 if @player.glyph_of_crusader_strike
    crit_chance += 0.05 * @player.talent_rule_of_law if @player.talent_rule_of_law
    return crit_chance
  end

  def off_cooldown
    @on_cooldown = false
    @cooldown_obj = nil
  end

  def cooldown_remaining
    return 0 unless @cooldown_obj
    return (@cooldown_obj.time - Runner.current_time) / 1000
  end


  def cooldown_if_cast_now
    # 4.5/(1+'Talents, Buffs, Enchants'!E18%)/(1+'Talents, Buffs, Enchants'!B17%)/
    # (1+('Talents, Buffs, Enchants'!K24+'Talents, Buffs, Enchants'!H34+Gear!S9+J12)%/'Base Numbers'!B6)
    cooldown = 4.5
    return cooldown unless @player.talent_sanctity_of_battle
    cooldown /= 1 + @player.calculated_haste(:magic) / 100
    return cooldown
  end


end
