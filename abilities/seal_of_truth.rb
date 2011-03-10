class SealOfTruth < Ability
  attr_reader :censure_stacks

  def initialize(player, mob)
    super

    @censure_stacks = 0
    @player.autoattack.extend(AutoAttackProc)
    # @next_censure_tick = nil
  end

  def reset
    super
    @next_censure_tick.kill if @next_censure_tick
    @next_censure_tick = nil
    @censure_stacks = 0
  end
  
  def seal_of_truth_dmg(weapon_dmg)
    raise "Not using seal of truth" unless @player.seal = :seal_of_truth
    raise "No censure stacks" if @censure_stacks <= 0

    # Seal of Truth has a very poor tooltip
    # Seems to deal 3% weapon damage per stack
    dmg = (@censure_stacks * 0.03)
    dmg *= weapon_dmg

    dmg *= @player.magic_bonus_multiplier(:holy)

    dmg *= 1.12 if @player.talent_seals_of_the_pure

    # two handed specialization
    dmg *= 1.2 

    attack = :hit

    # Seal of truth can't miss, be dodged, or glance 
    if random < @player.melee_crit_chance
      dmg *= @player.crit_multiplier(:physical) #TODO confirm
      attack = :crit
    end

    @mob.deal_damage(:seal_of_truth, :hit, dmg)
  end

  def autoattack_proc(weapon_dmg)
    raise "Not using seal of truth" unless @player.seal == :seal_of_truth

    seal_of_truth_dmg(weapon_dmg) if @censure_stacks > 0

    # Stack application is based on spell hit
    if random > @player.spell_miss_chance
      @censure_stacks += 1 unless @censure_stacks >= 5 
    end
    
    if @censure_stacks > 0 and @next_censure_tick.nil?
      @next_censure_tick = Event.new(self, "censure_dot_damage", @player.hasted_cast(3))   
    end

    seals_of_command_dmg(weapon_dmg) if @player.talent_seals_of_command 
  end

  def seals_of_command_dmg(weapon_dmg)
  # TODO validate this.  is it normalized weapon damage?
    dmg = 0.07 * weapon_dmg
    dmg *= @player.magic_bonus_multiplier(:holy)
    dmg *= 1.2 # two handed specialization

    attack = @player.special_attack_table

    case attack
      when :crit then dmg *= @player.crit_multiplier(:physical) # TODO confirm
    end
    
    @mob.deal_damage(:seals_of_command, attack, dmg)
  end

  def censure_dot_damage
    if(@censure_stacks <= 0 or @censure_stacks > 5)
      raise "Censure Stack Error"
    end

    dmg = 0.0192 * @player.calculated_attack_power
    dmg += 0.01 * @player.calculated_spell_power
    dmg *= @censure_stacks

    dmg *= @player.magic_bonus_multiplier(:holy)

    percent_bonus = @player.talent_inquiry_of_faith * 0.1 
    percent_bonus += 0.06 * @player.talent_seals_of_the_pure if @player.talent_seals_of_the_pure
    multiplier = 1 + percent_bonus
    dmg *= multiplier

    attack = :hit
    if random < @player.melee_crit_chance
      dmg *= @player.crit_multiplier(:physical) # TODO confirm
      attack = :crit
    end

    @mob.deal_damage(:censure, attack, dmg)
    @next_censure_tick = Event.new(self, "censure_dot_damage", @player.hasted_cast(3))   
  end
    
  module AutoAttackProc
    def use
      super
      if [:hit, :crit, :glancing].include?(@attack)
        @player.seal_of_truth.autoattack_proc(@weapon_dmg)
      end
    end
  end

end
