class AutoAttack < Ability

  def use
    dmg = @weapon_dmg = @sim.player.weapon_damage # keep track of base weapon damage for procs

    @attack = @sim.player.autoattack_table # keep track of last attack type (:hit, :crit, etc)

    case @attack
      when :crit then dmg *= @sim.player.crit_multiplier(:physical) 
      # No one knows how glancing blows work.  Basic testing shows an average of 25% reduction
      # This falls in line with limited testing (500 swings)
      when :glancing then dmg *= random(67,83)/100.0
    end

    dmg *= 1.2 # Ret bonus

    dmg *= @sim.player.physical_bonus_multiplier 

    dmg *= 1 - @sim.mob.damage_reduction_from_armor(@sim.player.level)

    @sim.mob.deal_damage(:melee, @attack, dmg)
   
    # Conventional wisdom and testing of similiar mechanics suggest that swing speed 
    # is instantly adjusted on haste procs.
    # However we are modeling using haste at time of last swing for simplicity
    # This will undervalue trinkets with haste procs.
    swing_speed = @sim.player.weapon_speed / (1 + @sim.player.calculated_haste(:physical) / 100)
    # TODO test with heroism / 4.0 weapon
    cooldown_up_in(swing_speed)
  end

  def off_cooldown
    super
    use
  end

end
