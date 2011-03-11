class Consecration < Ability
  
  def initialize(player, mob)
    super(player, mob)

    @remaining_dot_ticks = 0
  end

  def reset
    super
    @remaining_dot_ticks = 0
  end

  def use
    dmg = 810
    # Consecration scaling is currently bugged. 0.27 confirmed on my character
    # but results are different for others.
    # May need to make this configurable if Blizzard doesn't fix.
    dmg += @player.calculated_attack_power * 0.27
    dmg += @player.calculated_spell_power * 0.27

    dmg *= @player.magic_bonus_multiplier

     
  end
end
    
