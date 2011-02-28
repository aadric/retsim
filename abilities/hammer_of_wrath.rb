class HammerOfWrath

  def initialize(player, mob)
    @player = player
    @mob = mob
  end

  def use
    raise "Can't use Hammer of Wrath" unless @mob.flavor_country? or @player.avenging_wrath
    dmg = random(3815, 4215)
    dmg += @player.calculated_attack_power * 0.39
    dmg += @player.calculated_spell_power * 0.117

    dmg *= @player.magic_bonus_multiplier

    # Hammer of Wrath can miss based on melee hit but can't dodge or be parried


  end


  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.2 * @player.talent_sanctified_wrath if @player.talent_sanctified_wrath
    return crit_chance
  end

end
