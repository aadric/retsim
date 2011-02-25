class Mob
  attr_accessor :level, :type

  # Debuffs
  attr_accessor :debuff_armor,            # -12% armor, Faerie Fire, Sunder Armor, etc
                :debuff_physical_damage,  # 4% physical damage.  Brittle Bones, Blood Frenzy, etc
                :debuff_spell_damage,     # 8% spell damage. Master Poisoner, Curse of Elements, etc
                :debuff_spell_crit        # 5% spell crit. Critical Mass, Shadow and Flame, etc

  # Pali Debuffs
  attr_accessor :censure_stacks

  def initialize()
    @level = 83
    @armor = 11977
    @censure_stacks = 0
    @type = :unknown
  end


  def damage_reduction_from_armor(player_level)
    armor = @armor
    armor *= (1-0.12) if @minus_twelve_percent_armor
    
    reduction = armor / (armor + 2167.5 * player_level - 158167.5)  
  end
  
end
