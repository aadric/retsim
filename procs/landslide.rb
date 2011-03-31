class Landslide < SpecProc
  include ProcsPerMinute
  include Buff

  PPM = 1
  # TODO confirm what procs this
  PROCS_OFF_OF = %w{autoattack crusader_strike judgement templars_verdict} # Guesswork based off of righg eye of rajh

  def initialize(sim)
    super(sim)

    @sim.player.instance_variable_set(:@landslide, self)
    Player.send("attr_reader", :landslide)

    PROCS_OFF_OF.each do |ability_name|
      @sim.player.send(ability_name).extend(ProcLandslide)
    end

    @sim.player.extend(AugmentPlayerAttackPower)
  end

  def use
    # do nothing
  end

  def proc_attempt
    if random < pph(PPM)
      buff_expires_in(12)
    end
  end

  module ProcLandslide
    def use
      super
      unless [:miss, :dodge].include?(@attack)
        @sim.player.landslide.proc_attempt
      end
    end
  end

  module AugmentPlayerAttackPower
    def attack_power
      ap = super
      ap += 1000 if @landslide.active?
      return ap
    end
  end

end
