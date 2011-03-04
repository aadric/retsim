class Ability

  def initialize(player, mob)
    @player = player
    @mob = mob
  end

  # Called when resetting entire fight. Usually because mob health has run out
  # and we're starting a new fight
  def reset
    @cooldown_reset_event = nil
  end

  # Called when cooldown is up, or when cooldown is reset via talent or ability
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
    return (@cooldown_reset_event.time - Runner.current_time) / 1000
  end

  def useable?
    return false if on_cooldown?
    return true
  end

end
