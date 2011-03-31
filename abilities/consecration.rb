class Consecration < Ability
  
  def initialize(sim)
    super(sim)

    @remaining_ticks = 0
  end

  def reset
    super
    @remaining_ticks = 0
    @next_tick_event.kill if @next_tick_event
    @next_tick_event = nil
  end

  def use
    raise "Can't use conseration yet" unless usable?

    reset # This line would be important if you could overwrite consecrate 

    # Tests indicated 27% scaling with AP and SP
    # http://elitistjerks.com/f76/t110335-paladin_simple_questions_cataclysmic_mode/p4/#post1889388

    @dmg = 810

    @dmg += @sim.player.calculated_attack_power * 0.27
    @dmg += @sim.player.calculated_spell_power * 0.27


    @remaining_ticks = @sim.player.glyph_of_consecration ? 12 : 10

    cooldown = @sim.player.glyph_of_consecration ? 36 : 30
    cooldown_up_in(cooldown) 

    @next_tick_event = @sim.new_event(self, "tick", 1) 

    @sim.player.lock_gcd(:hasted => true)
  end

  def tick
    # Turning your aura on/off changes damage instantly
    # TODO confirm works with inquisition
    dmg = @dmg * @sim.player.magic_bonus_multiplier / 10

    attack = @sim.player.spell_table

    dmg *= @sim.player.crit_multiplier(:magic) if attack == :crit

    @sim.mob.deal_damage(:consecration, attack, dmg.prob_round)
    @remaining_ticks -= 1
    if @remaining_ticks > 0
      # Haste does not increase the speed of Consecration ticks
      # http://maintankadin.failsafedesign.com/forum/index.php?p=641054&rb_v=viewtopic#p641054 
      @next_tick_event = @sim.new_event(self, "tick", 1)
    end
  end
end
