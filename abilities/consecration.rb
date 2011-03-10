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
    # TODO confirm all mechanics of consecration
    dmg = 810
    dmg += @player.calculated_attack_power * 0.27
    dmg += @player.calculated_spell_power * 0.27

    dmg *= @player.magic_bonus_multiplier
    # TODO everything
  end
end
    
