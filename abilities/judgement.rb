class Judgement
  attr_reader :on_cooldown

  def initialize(player, mob)
    @mob = mob
    @player = player
    @on_cooldown = false
  end

  def use
    raise "Judgement still on cooldown" if @on_cooldown

    dmg = @player.calculated_attack_power * 0.1421
    dmg += @player.calculated_spell_power * 0.2229

    dmg *= @player.magic_bonus_multiplier

    dmg *= 1 + (0.1 * @mob.censure_stacks)

    dmg *= 1.1 if @player.glyph_of_judgement

    dmg *= 1.2 if @player.two_handed_specialization

    dmg *= 1.2 if @player.avenging_wrath.active? # TODO confirm

    attack = @player.special_attack_table(:crit_chance => crit_chance, :ranged => true)

    dmg *= @player.crit_multiplier(:physical) if attack == :crit

    @mob.deal_damage(:judgement, attack, dmg.round) # TODO compare name of attack to recount

    @on_cooldown = true
    Event.new(self, "clear_cooldown", 8)

    @player.is_gcd_locked = true
    Event.new(@player, "clear_gcd", 1.5)
  end

  def clear_cooldown
    @on_cooldown = false
  end

  def crit_chance
    crit_chance = @player.melee_crit_chance
    crit_chance += 0.06 * @player.talent_arbiter_of_the_light if @player.talent_arbiter_of_the_light
  end

  def reset
    clear_cooldown
  end
    
end
