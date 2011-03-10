class Ability

  def initialize(player, mob)
    @player = player
    @mob = mob
  end

  def reset
    off_cooldown
    clear_buff
  end

  # Called when cooldown is up, or when cooldown is reset via talent or ability
  def off_cooldown
    @cooldown_reset_event.kill if @cooldown_reset_event # Only used when clearing cooldown early
    @cooldown_reset_event = nil
  end

  def on_cooldown?
    @cooldown_reset_event ? true : false
  end

  def usable?
    return false if on_cooldown?
    true
  end

  # Returns time until cooldown is up in seconds
  def cooldown_remaining
    return 0 unless @cooldown_reset_event
    return (@cooldown_reset_event.time - Runner.current_time) / 1000
  end

  def cooldown_up_in(seconds)
    @cooldown_reset_event = Event.new(self, "off_cooldown", seconds)
  end

  def clear_buff
    @clear_buff_event.kill if @clear_buff_event
    @clear_buff_event = nil
  end

  def active?
    @clear_buff_event ? true : false
  end

  def buff_remaining
    return 0 unless @clear_buff_event
    return (@clear_buff_event.time - Runner.current_time) / 1000
  end 

  def buff_expires_in(seconds)
    @clear_buff_event.kill if @clear_buff_event
    @clear_buff_event = Event.new(self, "clear_buff", seconds)
  end

end
