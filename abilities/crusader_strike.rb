class CrusaderStrike
  attr_accessor :on_cooldown

  def initialize(player, mob)
    @mob = mob
    @player = player
    @on_cooldown = false
  end

  def use(current_time)
    dmg = @player.weapon_damage * 1.35 

    dmg *= @player.physical_bonus_multiplier

    dmg *= 1 - @mob.damage_reduction_from_armor(@player.level)

    dmg *= 1 + (@player.talent_crusade * 0.10) if @player.talent_crusade
    dmg *= 1.2

    dmg *= 1.2 if @player.avenging_wrath

    attack = @player.attack_table(:melee_special, crit_chance)

    case attack
      when :crit then dmg *= @player.crit_multiplier(:physical)
      when :miss then dmg = 0
      when :dodge then dmg = 0
    end

    Statistics.instance.log_damage_event(:crusader_strike, attack, dmg.round)

    @cooldown_obj = Event.new(self, "off_cooldown", current_time + cooldown_if_cast_now * 1000, :crusader_strike)
    @on_cooldown = true

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", current_time + 1.5 * 1000)

    @player.holy_power += 1 unless @player.holy_power == 3
  end

  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.05 if @player.glyph_of_crusader_strike
    crit_chance += 0.05 * @player.talent_rule_of_law if @player.talent_rule_of_law
    return crit_chance
  end

  def off_cooldown(current_time)
    @on_cooldown = false
    @cooldown_obj = nil
  end

  def cooldown_remaining(current_time)
    return 0 unless @cooldown_obj
    return (@cooldown_obj.time - current_time) / 1000
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
