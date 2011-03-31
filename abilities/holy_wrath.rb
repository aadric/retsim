class HolyWrath < Ability

  def initialize(player, mob)
    @player = player
    @mob = mob
    @on_cooldown = false
  end


  def use
    raise "Holy Wrath on cooldown" unless usable?

    dmg = 2402 # TODO confirm
    dmg += 0.61 * @player.calculated_spell_power

    dmg *= @player.magic_bonus_multiplier

    attack = @player.spell_table
    dmg *= @player.crit_multiplier(:magic) if attack == :crit

    @mob.deal_damage(:holy_wrath, attack, dmg)

    @player.lock_gcd(:hasted => true)

    cooldown_up_in(15)
  end

end
