class LicenseToSlay < SpecProc # What is the lore behind this item?
  PROCS_OFF_OF = %w{autoattack crusader_strike hammer_of_wrath templars_verdict} # TODO confirm

  attr_reader :stacks

  def initialize(sim)
    super(sim)

    @sim.player.instance_variable_set(:@license_to_slay, self)
    Player.send("attr_reader", :license_to_slay)

    @stacks = 0

    PROCS_OFF_OF.each do |ability_name|
      @sim.player.send(ability_name).extend(ProcTrinket)
    end

    @sim.player.extend(AugmentPlayerStrength)
  end

  def reset
    clear_stacks
  end
  
  def clear_stacks
    # TODO clearing event
    @stacks = 0
  end

  def use
    # Do nothing
  end

  def proc
    @stacks += 1 unless @stacks == 10
    # TODO stack fall off
  end

  module ProcTrinket
    def use
      super
      unless [:miss, :dodge].include?(@attack)
        @sim.player.license_to_slay.proc
      end
    end
  end

  module AugmentPlayerStrength
    def additive_strength_from_buffs_and_consumables
      str = 38 * @license_to_slay.stacks

      return (str + super)
    end
  end

end
