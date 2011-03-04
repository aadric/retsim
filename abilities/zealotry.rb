class Zealotry < Ability

  def initialize(player)
    super(player, nil)
    @active = false

    @player.crusader_strike.extend(ZealotryCheck)
  end

  def reset
    super
    @active = false
  end


  def use
    raise "Can't use Zealotry yet" unless useable?

    @active = true
    @cooldown_reset_event = Event.new(self, "off_cooldown", 2 * 60)

    Event.new(self, "clear_buff", 20)
    # Zealotry is off the GCD
  end

  def clear_buff
    @active = false
  end

  def useable?
    super and (@player.divine_purpose.active or @player.holy_power == 3)
  end

  def active?
    @active
  end

  module ZealotryCheck
    def increase_holy_power
      if @player.zealotry.active?
        # TODO log statistics
        @player.holy_power = 3 if @player.zealotry.active?
      else
        super
      end
    end
  end

end  
