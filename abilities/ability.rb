class Ability
  # TODO modularize this like trinkets

  def initialize(sim)
    @sim = sim
  end

  def reset
    off_cooldown
    clear_buff(:reset => true)
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
    return (@cooldown_reset_event.time - @sim.runner.current_time) / 1000.0
  end

  def cooldown_up_in(seconds)
    @cooldown_reset_event = @sim.new_event(self, "off_cooldown", seconds)
  end

  def clear_buff(opts = {})
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
