class Mob
  attr_accessor :level, :type, :armor, :health

  # Debuffs
  attr_accessor :debuff_armor,            # -12% armor, Faerie Fire, Sunder Armor, etc
                :debuff_physical_damage,  # 4% physical damage.  Brittle Bones, Blood Frenzy, etc
                :debuff_spell_damage,     # 8% spell damage. Master Poisoner, Curse of Elements, etc
                :debuff_spell_crit        # 5% spell crit. Critical Mass, Shadow and Flame, etc

  def initialize(sim)
    @sim = sim
    @damage_dealt = 0
  end

  def reset
    @damage_dealt = 0
  end

  def damage_reduction_from_armor(player_level)
    armor = @armor
    armor *= (1-0.12) if debuff_armor
    
    reduction = armor / (armor + 2167.5 * player_level - 158167.5)
  end

  def deal_damage(ability, type, dmg)
    dmg = dmg.round # Should probably use probalistic rounding
    raise "Invalid attack type" unless [:miss, :dodge, :hit, :crit, :glancing].include?(type)
    dmg = 0 if [:miss, :dodge].include?(type)
    @damage_dealt += dmg
    @sim.stats.log_damage(ability, type, dmg)
  end

  def remaining_damage
    return [0, @health - @damage_dealt].max
  end

  # At or less than 20% health
  def flavor_country?
    if @sim.run_mode == :boss_health
      return (@health - @damage_dealt)/@health.to_f <= 0.20
    end
    if @sim.run_mode == :time
      return (@sim.runner.current_time - @sim.runner.start_time) / 1000.0 >= (@sim.runner.fight_length * 0.82)
    end
    raise "Error, unknown run type"
  end
end
