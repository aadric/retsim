# Any complicated trinket, enchant, or tinker (not ret specific)
class SpecProc # "Proc" is a reserved word in Ruby

  def initialize(sim)
    @sim = sim
  end

  def reset
    off_cooldown if kind_of?(OnUseCooldown)
    off_internal_cooldown if kind_of?(InternalCooldown)
    clear_buff if kind_of?(Buff)
  end

  module ProcsPerMinute

    # Calculates procs per hit based on un-hasted weapon speed
    def pph(ppm)
      # http://www.wowpedia.org/Ppm 
      # PPH is unaffected by haste
      @sim.player.weapon_speed * ppm / 60
    end
  end
    

  module OnUseCooldown
    def off_cooldown
      @cooldown_reset_event.kill if @cooldown_reset_event # Only used when clearing cooldown early
      @cooldown_reset_event = nil
    end

    def on_cooldown?
      @cooldown_reset_event ? true : false
    end

    # Returns time until cooldown is up in seconds
    def cooldown_remaining
      return 0 unless @cooldown_reset_event
      return (@cooldown_reset_event.time - @sim.runner.current_time) / 1000
    end

    def usable?
      return false if on_cooldown?
      true
    end

    def cooldown_up_in(seconds)
      @cooldown_reset_event = @sim.new_event(self, "off_cooldown", seconds)
    end
  end

  module InternalCooldown
    def off_internal_cooldown
      @internal_cooldown_reset_event.kill if @internal_cooldown_reset_event # Only used when clearing cooldown early
      @internal_cooldown_reset_event = nil
    end

    def on_internal_cooldown?
      @internal_cooldown_reset_event ? true : false
    end

    def internal_cooldown_up_in(seconds)
      @internal_cooldown_reset_event = @sim.new_event(self, "off_internal_cooldown", seconds)
    end
  end

  module Buff
    def clear_buff
      @clear_buff_event.kill if @clear_buff_event
      @clear_buff_event = nil
    end

    def active?
      @clear_buff_event ? true : false
    end

    def buff_remaining
      return 0 unless @clear_buff_event
      return (@clear_buff_event.time - @sim.runner.current_time) / 1000
    end 

    def buff_expires_in(seconds)
      @clear_buff_event.kill if @clear_buff_event
      @clear_buff_event = @sim.new_event(self, "clear_buff", seconds)
    end
  end
end
