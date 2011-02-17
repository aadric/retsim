class Mob
  attr_accessor :level

  # Debuffs
  attr_accessor :debuff_crit_chance_taken,
                :minus_twelve_percent_armor,
                :censure_stacks,
                :eight_percent_spell_damage_taken

  def initialize()
    @level = 83
    @armor = 11977
    @censure_stacks = 0
  end


  def damage_reduction_from_armor(player_level)
    armor = @armor
    armor *= (1-0.12) if @minus_twelve_percent_armor
    
    reduction = armor / (armor + 2167.5 * player_level - 158167.5)  
  end
  
end
