class Consecration
  
  def initialize(player, mob)
    @player = player
    @mob = mob

    @remaining_dot_ticks = 0
    @on_cooldown = false
  end

  def reset
    clear_cooldown
    @remaining_dot_ticks = 0
    @damage = 0
    @damage_remaining = 0
  end

  def use
    # TODO confirm all mechanics of consecration
    dmg = 810
    dmg += @player.calculated_attack_power * 0.26
    dmg += @player.calculated_spell_power * 0.26

    dmg *= @player.magic_bonus_multiplier
    # TODO everything
  end
end
    
