class TemplarsVerdict

  def initialize(player, mob)
    @player = player
    @mob = mob
    @dmg = 0
    @count = 0
  end

  def reset
  end


  def use
    raise "No Holy Power for Templar's Verdict" unless @player.has_holy_power

    if @player.divine_purpose_proc
      modifier = 2.35
    else
      case @player.holy_power
        when 1 then modifier = 0.30
        when 2 then modifier = 0.90
        when 3 then modifier = 2.35
      end
    end


    dmg = @player.weapon_damage * modifier

    # @dmg += dmg
    # @count += 1
    # puts (@dmg / @count).to_s if @count % 100 == 0

    dmg *= @player.physical_bonus_multiplier
    dmg *= 1 - @mob.damage_reduction_from_armor(@player.level)

    # TODO confirm these are additive
    modifier = 1
    modifier += 0.15 if @player.glyph_of_templars_verdict
    modifier += @player.talent_crusade * 0.10 if @player.talent_crusade
    modifier += 0.10 if @player.set_bonus_t11_two_piece

    dmg *= modifier

    dmg *= 1.2


    attack = @player.special_attack_table(:crit_chance => crit_chance)
    case attack
      when :crit then dmg *= @player.crit_multiplier(:physical)
      when :miss then dmg = 0
      when :dodge then dmg = 0
    end
    @mob.deal_damage(:templars_verdict, attack, dmg.round)

    # We keep our holy power on a dodge or a miss
    unless [:miss, :dodge].include?(attack)
      if @player.divine_purpose_proc
        @player.divine_purpose_proc.kill
        @player.divine_purpose_proc = nil
      else
        @player.holy_power = 0
      end
    end

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", 1.5)

    @player.divine_purpose_roll
  end

  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.06 * @player.talent_arbiter_of_the_light if @player.talent_arbiter_of_the_light
    crit_chance
  end

end
