class FuryOfAngerforge346 < Trinket # Best item name ever
  include Buff
  include OnUseCooldown
  include InternalCooldown

  INTERNAL_COOLDOWN = 5 # From wowhead comments. TODO confirm
  PROC_CHANCE = 0.5 # From http://www.wowhead.com/spell=91833 
  COOLDOWN = 2 * 60
  DURATION = 20
  # TODO confirm below
  PROCS_OFF_OF = %w{autoattack crusader_strike hammer_of_wrath templars_verdict} # Guesswork based off of righg eye of rajh

  def initialize(player, mob)
    super(player, mob)

    @stacks = 0

    player.instance_variable_set(:@fury_of_angerforge_346, self)
    Player.send("attr_reader", :fury_of_angerforge_346)

    PROCS_OFF_OF.each do |ability_name|
      player.send(ability_name).extend(ProcTrinket)
    end

    player.extend(AugmentPlayerStrength)
  end


  def use
    return unless usable?
    return if @player.trinkets_locked?

    @active = true
    buff_expires_in(DURATION)
    cooldown_up_in(COOLDOWN)
    
    clear_stacks

    @player.lockout_trinkets(20) # TODO confirm 
  end

  def usable?
    return (super and @stacks == 5)
  end

  def try_to_proc
    unless on_internal_cooldown? or random > PROC_CHANCE
      @stacks += 1
      @stack = 5 if @stacks > 5
      internal_cooldown_up_in(INTERNAL_COOLDOWN)
      clear_stacks_in(10)
    end
  end

  def clear_stacks_in(seconds)
    @clear_stacks_event.kill if @clear_stacks_event
    @clear_stacks_event = Event.new(self, "clear_stacks", seconds)
  end

  def clear_stacks
    @clear_stacks_event.kill if @clear_stacks_event
    @clear_stacks_event = nil
    @stacks = 0
  end

  module ProcTrinket
    def use
      super
      unless [:miss, :dodge].include?(@attack)
        @player.fury_of_angerforge_346.try_to_proc
      end
    end
  end

  module AugmentPlayerStrength
    def additive_strength_from_buffs_and_consumables
      return super unless @fury_of_angerforge_346.active?

      return (1926 + super)
    end
  end

end
