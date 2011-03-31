# Not exactly a trinket
class SynapseSprings < SpecProc
  include OnUseCooldown
  include Buff

  DURATION = 10
  COOLDOWN = 60
  
  def initialize(sim)
    super(sim)
    
    @sim.player.instance_variable_set(:@synapse_springs, self)
    Player.send("attr_reader", :synapse_springs)

    @sim.player.extend(AugmentPlayerStrength)
  end

  def use
    return if @sim.player.trinkets_locked?
    return unless usable?

    @active = true
    buff_expires_in(DURATION)
    cooldown_up_in(COOLDOWN)

    @sim.player.lockout_trinkets(20) # TODO Confirm value
  end

  module AugmentPlayerStrength
    def additive_strength_from_buffs_and_consumables
      return super unless @synapse_springs.active?
      return (480 + super)
    end
  end
end
