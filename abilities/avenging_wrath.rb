class AvengingWrath
  
  def initialize(player)
    @player = player
  end

  def use
    @active = true

    cooldown = 3 * 60 # 3 minutes

    cooldown -= 20 * @player.talent_sanctified_wrath if @player.talent_sanctified_wrath # Less 20 seconds per point in talent

    @cooldown_reset_event = Event.new(self, "off_cooldown", cooldown)

    Event.new(self, "clear_buff", 20)

    # Avenging Wrath is off the GCD
  end

  def reset
    @cooldown_reset_event = nil
    @active = false
  end

  def off_cooldown
    @cooldown_reset_event = nil
  end 

  def on_cooldown?
    @cooldown_reset_event ? true : false
  end

  def clear_buff
    @active = false
  end

  def active?
    @active ? true : false
  end

  def cooldown_remaining
    return 0 unless @cooldown_reset_event
    return (@cooldown_reset_event.time - Runner.current_time) / 1000
  end
end
