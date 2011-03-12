class Consecration < Ability
  
  def initialize(player, mob)
    super(player, mob)

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

    reset # We don't need to do this because you can't overlap a cast right now

    # wowhead is wrong, all tests indicated 27% scaling with AP and SP
    # http://elitistjerks.com/f76/t110335-paladin_simple_questions_cataclysmic_mode/p4/#post1889388

    @dmg = 810

    # TODO confirm this

    @dmg += @player.calculated_attack_power * 0.27
    @dmg += @player.calculated_spell_power * 0.27


    @remaining_ticks = @player.glyph_of_consecration ? 12 : 10

    cooldown = @player.glyph_of_consecration ? 36 : 30
    cooldown_up_in(cooldown) 

    @next_tick_event = Event.new(self, "tick", 1) 
  end

  def tick
    # Turning your aura on/off changes damage instantly
    # TODO confirm works with inquisition
    dmg = @dmg * @player.magic_bonus_multiplier / 10

    attack = @player.spell_table

    dmg *= @player.crit_multiplier(:magic) if attack == :crit

    @mob.deal_damage(:consecration, attack, dmg.prob_round)
    @remaining_ticks -= 1
    if @remaining_ticks > 0
      # Haste does not increase the speed of Consecration ticks
      # http://maintankadin.failsafedesign.com/forum/index.php?p=641054&rb_v=viewtopic#p641054 
      @next_tick_event = Event.new(self, "tick", 1)
    end
  end
end


