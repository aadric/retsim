class Mob
  attr_accessor :level

  # Debuffs
  attr_accessor :debuff_crit_chance_taken 
  attr_accessor :minus_twelve_percent_armor  
  attr_accessor :censure_stacks

  def initialize()
    @level = 83
    @armor = 11977
    @censure_stacks = 5
  end


  def damage_reduction_from_armor(player_level)
    armor = @armor
    armor *= (1-0.12) if @minus_twelve_percent_armor
    
    reduction = armor / (armor + 2167.5 * player_level - 158167.5)  
  end
  
end
