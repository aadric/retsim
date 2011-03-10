class Mob
  attr_accessor :level, :type, :armor, :health

  # Debuffs
  attr_accessor :debuff_armor,            # -12% armor, Faerie Fire, Sunder Armor, etc
                :debuff_physical_damage,  # 4% physical damage.  Brittle Bones, Blood Frenzy, etc
                :debuff_spell_damage,     # 8% spell damage. Master Poisoner, Curse of Elements, etc
                :debuff_spell_crit        # 5% spell crit. Critical Mass, Shadow and Flame, etc

  def initialize()
    @censure_stacks = 0
    @damage_dealt = 0
  end

  def reset
    @damage_dealt = 0
    @censure_stacks = 0
  end

  def damage_reduction_from_armor(player_level)
    armor = @armor
    armor *= (1-0.12) if @minus_twelve_percent_armor
    
    reduction = armor / (armor + 2167.5 * player_level - 158167.5)
  end

  def deal_damage(ability, type, dmg)
    dmg = dmg.round # Should probably use probalistic rounding
    raise "Invalid attack type" unless [:miss, :dodge, :hit, :crit, :glancing].include?(type)
    dmg = 0 if [:miss, :dodge].include?(type)
    @damage_dealt += dmg
    Statistics.instance.log_damage(ability, type, dmg)
  end

  def remaining_damage
    return [0, @health - @damage_dealt].max
  end

  # At or less than 20% health
  def flavor_country?
    return (@health - @damage_dealt)/@health.to_f <= 0.20
  end
  
end
