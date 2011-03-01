class HolyWrath
  attr_reader :on_cooldown

  def initialize(player, mob)
    @player = player
    @mob = mob
    @on_cooldown = false
  end

  def reset
    @on_cooldown = false
  end

  def use
    raise "Holy Wrath on cooldown" if @on_cooldown

    dmg = 2402 # TODO confirm
    dmg += 0.61 * @player.calculated_spell_power

    dmg *= @player.magic_bonus_multiplier

    attack = @player.spell_table
    case attack
      when :miss then dmg = 0
      when :crit then dmg *= @player.crit_multiplier(:magic)
    end

    @mob.deal_damage(:holy_wrath, attack, dmg.round)

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", @player.hasted_cast)

    @on_cooldown = true
    Event.new(self, "clear_cooldown", 15)
  end

  def clear_cooldown
    @on_cooldown = false
  end
end
