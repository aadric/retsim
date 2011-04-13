class Exorcism < Ability

  attr_accessor :remaining_dot_ticks
  attr_accessor :next_dot_event
  attr_accessor :primary_dmg          # How much damage did exorcism hit for, for purposes of calcultating dot damage

  def initialize(sim)
    super(sim)

    @remaining_dot_ticks = 0

    @sim.player.autoattack.extend(ProcOnAutoAttack)
  end

  def reset
    super
    @remaining_dot_ticks = 0
    @art_of_war_proc = nil
    @next_dot_event.kill if @next_dot_event
    @next_dot_event = nil
    @primary_dmg = nil
  end

  def art_of_war_proc?
    @art_of_war_proc ? true : false
  end

  def usable?
    @art_of_war_proc and !@sim.player.gcd_locked?
  end

  def use
    return unless usable?
    # assume we only cast this when a proc is up
    @art_of_war_proc = false
    # TODO clear event that would clear this proc since we just used it

    dmg = random(2591, 2891)

    dmg += @sim.player.calculated_attack_power * 0.344

    dmg *= @sim.player.magic_bonus_multiplier

    talent_multiplier = 1
    talent_multiplier += 0.10 * @sim.player.talent_blazing_light
    talent_multiplier += 1 # assume art of war proc

    dmg *= talent_multiplier

    @primary_dmg = dmg.round

    crit_chance = 1 if @sim.mob.type == :undead or @sim.mob.type == :demon

    @attack = @sim.player.spell_table(crit_chance)

    dmg *= @sim.player.crit_multiplier(:magic) if @attack == :crit

    @sim.mob.deal_damage(:exorcism, @attack, dmg.round)
    
    if @sim.player.glyph_of_exorcism and @attack != :miss # I'm assuming the dot application can't miss independant of exorcism
      # If there is a dot on it, the dot is removed TODO validate this behavior 
      @next_dot_event.kill if @next_dot_event
      # TODO confirm glyph dot is sped up by haste
      @next_dot_event = @sim.new_event(self, "dot_damage", @sim.player.hasted_cast(2))
      @remaining_dot_ticks = 3
    end

    @sim.player.lock_gcd(:hasted => true)
  end

  def proc_art_of_war
    @art_of_war_proc = true
    # TODO add event to clear proc if it isn't used in time
  end

  def dot_damage
    dmg = @primary_dmg * 0.20 / 3 
    attack = :hit
    if random < @sim.player.spell_crit_chance or [:undead, :demon].include?(@sim.mob.type) # TODO confirm the dots can crit
      attack = :crit
      dmg *= @sim.player.crit_multiplier(:magic)
    end
    @sim.mob.deal_damage(:exorcism_dot, attack, dmg.round)
    @remaining_dot_ticks -= 1
    @next_dot_event = @sim.new_event(self, "dot_damage", @sim.player.hasted_cast(2)) if @remaining_dot_ticks > 0
  end

  module ProcOnAutoAttack
    def use
      super
      if @sim.player.talent_art_of_war and [:hit, :crit, :glancing].include?(@attack)
        proc_chance = [0.20, 0.07 * @sim.player.talent_art_of_war].min # 0.00, 0.07, 0.14, 0.20
        @sim.player.exorcism.proc_art_of_war if random < proc_chance
      end
    end
  end

end
