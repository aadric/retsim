class DivinePurpose < Ability

  def initialize(sim)
    super(sim)

    # Divine Purpose can Proc off the following attacks
    @sim.player.judgement.extend(DivinePurposeRoll)
    @sim.player.exorcism.extend(DivinePurposeRoll)
    @sim.player.templars_verdict.extend(DivinePurposeRoll)
    @sim.player.inquisition.extend(DivinePurposeRoll)
    @sim.player.holy_wrath.extend(DivinePurposeRoll)
    @sim.player.hammer_of_wrath.extend(DivinePurposeRoll)
    # TODO DS
  end

  def roll
    return unless @sim.player.talent_divine_purpose > 0
    chance = @sim.player.talent_divine_purpose == 1 ? 0.07 : 0.15 

    if random < chance
      buff_expires_in(8) # TODO confirm this is 8 seconds
    end
  end

  module DivinePurposeRoll
    def use
      super
      # TODO can divine purpose proc off misses/dodges?
      @sim.player.divine_purpose.roll
    end
  end

end
