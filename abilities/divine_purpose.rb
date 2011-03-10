class DivinePurpose < Ability

  def initialize(player)
    super(player, nil)

    # Divine Purpose can Proc off the following attacks
    @player.judgement.extend(DivinePurposeRoll)
    @player.exorcism.extend(DivinePurposeRoll)
    @player.templars_verdict.extend(DivinePurposeRoll)
    @player.inquisition.extend(DivinePurposeRoll)
    # TODO DS
    @player.holy_wrath.extend(DivinePurposeRoll)
    @hammer_of_wrath.extend(DivinePurposeRoll)

    @player.extend(DivinePurposeReset)
  end

  def roll
    return unless @player.talent_divine_purpose and @player.talent_divine_purpose > 0
    chance = @player.talent_divine_purpose == 1 ? 0.07 : 0.15 

    if random < chance
      buff_expires_in(8) # TODO confirm this is 8 seconds
    end
  end

  module DivinePurposeRoll
    def use
      super
      @player.divine_purpose.roll
    end
  end

  module DivinePurposeReset
    def reset
      super
      divine_purpose.reset
    end
  end
end
