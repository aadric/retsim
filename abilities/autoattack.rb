class AutoAttack < Ability

  def use
    dmg = @weapon_dmg = @player.weapon_damage # keep track of base weapon damage for procs

    @attack = @player.autoattack_table # keep track of last attack type (:hit, :crit, etc)

    case @attack
      when :crit then dmg *= @player.crit_multiplier(:physical) 
      # No one knows how glancing blows work.  Basic testing shows an average of 25% reduction
      # This falls in line with limited testing (500 swings)
      when :glancing then dmg *= random(67,83)/100.0
    end

    dmg *= 1.2 # Ret bonus

    dmg *= @player.physical_bonus_multiplier 

    dmg *= 1 - @mob.damage_reduction_from_armor(@player.level)

    @mob.deal_damage(:melee, @attack, dmg)
   
    # TODO
    # I think technically swing speed is augmented instantly by haste.
    # For now modeling as if its based on haste when swinging
    swing_speed = @player.weapon_speed / (1 + @player.calculated_haste(:physical) / 100)
    @cooldown_reset_event = Event.new(self, "off_cooldown", swing_speed)
    @on_cooldown = true
  end

  def off_cooldown
    super
    use
  end

end
