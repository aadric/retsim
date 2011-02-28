class Exorcism

  attr_accessor :art_of_war_proc
  attr_accessor :remaining_dot_ticks
  attr_accessor :next_dot_event
  attr_accessor :primary_dmg          # How much damage did exorcism hit for, for purposes of calcultating dot damage

  def initialize(player, mob)
    @player = player
    @mob = mob

    @remaining_dot_ticks = 0
  end


  def use
    # assume we only cast this when a proc is up
    @art_of_war_proc = false
    # TODO clear event that would clear this proc since we just used it

    dmg = random(2592, 2892)
    #dmg += @player.calculated_attack_power * 0.344
    dmg += @player.calculated_attack_power * 0.344
    dmg *= @player.magic_bonus_multiplier

    talent_multiplier = 1
    talent_multiplier += 0.10 * @player.talent_blazing_light if @player.talent_blazing_light
    talent_multiplier += 1 # assume art of war proc

    dmg *= talent_multiplier

    @primary_dmg = dmg.round

    crit_chance = 1 if @mob.type == :undead or @mob.type == :demon

    attack = @player.spell_table(crit_chance)
    case attack
      when :miss then dmg = 0
      when :crit then dmg *= @player.crit_multiplier(:magic)
    end

    @mob.deal_damage(:exorcism, attack, dmg.round)
    
    if @player.glyph_of_exorcism and attack != :miss # I'm assuming the dot application can't miss independant of exorcism
      # If there is a dot on it, the dot is removed TODO validate this behavior 
      @next_dot_event.kill if @next_dot_event
      # TODO confirm glyph dot is sped up by haste
      @next_dot_event = Event.new(self, "dot_damage", @player.hasted_cast(2))
      @remaining_dot_ticks = 3
    end

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", @player.hasted_cast)
    @player.divine_purpose_roll
  end

  def proc_art_of_war
    @art_of_war_proc = true
    # TODO add event to clear proc if it isn't used in time
  end

  def dot_damage
    dmg = @primary_dmg * 0.20 / 3 
    attack = :hit
    if random < @player.spell_crit_chance or [:undead, :demon].include?(@mob.type) 
      attack = :crit
      dmg *= @player.crit_multiplier(:magic)
    end
    @mob.deal_damage(:exorcism_dot, attack, dmg.round)
    @remaining_dot_ticks -= 1
    @next_dot_event = Event.new(self, "dot_damage", @player.hasted_cast(2)) if @remaining_dot_ticks > 0
  end

end
