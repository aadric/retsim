class HammerOfWrath < Ability

  def use
    raise "Can't use Hammer of Wrath" unless usable?

    dmg = random(3815, 4215)
    dmg += @sim.player.calculated_attack_power * 0.39
    dmg += @sim.player.calculated_spell_power * 0.117

    dmg *= @sim.player.magic_bonus_multiplier

    # Hammer of Wrath can miss based on melee hit but can't dodge or be parried
    @attack = @sim.player.special_attack_table(:ranged => true, :crit_chance => crit_chance)

    dmg *= @sim.player.crit_multiplier(:physical) if @attack == :crit

    @sim.mob.deal_damage(:hammer_of_wrath, @attack, dmg)
    
    cooldown_up_in(6)

    @sim.player.lock_gcd
  end


  def usable?
    super and (@sim.mob.flavor_country? or @sim.player.avenging_wrath.active?)
  end

  def crit_chance
    crit_chance = @sim.player.melee_crit_chance
    crit_chance += 0.2 * @sim.player.talent_sanctified_wrath 
    return crit_chance
  end

end
