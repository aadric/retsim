class HammerOfWrath < Ability

  def use
    raise "Can't use Hammer of Wrath" unless usable?

    dmg = random(3815, 4215)
    dmg += @player.calculated_attack_power * 0.39
    dmg += @player.calculated_spell_power * 0.117

    dmg *= @player.magic_bonus_multiplier

    # Hammer of Wrath can miss based on melee hit but can't dodge or be parried
    @attack = @player.special_attack_table(:ranged => true, :crit_chance => crit_chance)

    dmg *= @player.crit_multiplier(:physical) if @attack == :crit

    @mob.deal_damage(:hammer_of_wrath, @attack, dmg)
    
    cooldown_up_in(6)

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", 1.5)
  end


  def usable?
    super and (@mob.flavor_country? or @player.avenging_wrath.active?)
  end

  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.2 * @player.talent_sanctified_wrath if @player.talent_sanctified_wrath
    return crit_chance
  end

end
