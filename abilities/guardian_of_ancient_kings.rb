class GuardianOfAncientKings < Ability
  # Basic testing shows following:
  # 1. Damage unaffected by player stats
  # 2. Pet misses and dodges a lot, even when player is capped
  # 3. Pet can crit even when player can't melee crit
  # 4. Armor debuff doesn't increase damage (TODO confirm)
  #
  # Pet is also very bad about standing behind target dummys
  # but doesn't seem to have this problem on bosses, so I'm not accounting
  # for any parries or blocks.

  attr_reader :buff_count

  # TODO judgement?
  PROCS_OFF_OF = %w{autoattack crusader_strike hammer_of_wrath templars_verdict} # Guesswork based off of righg eye of rajh

  
  def initialize(sim)
    super(sim)
    @buff_count = 0

    @sim.player.extend(AugmentPlayerStrength)

    PROCS_OFF_OF.each do |ability_name|
      @sim.player.send(ability_name).extend(ProcAncientPower)
    end
  end
  
  def use
    @buff_count = 0

    # Realistically, the pet doesn't hit right away
    # Add a little buffer before the first attack to ensure we get 15 hits instead of 16
    @pet_damage_event = @sim.new_event(self, "pet_damage", 0.2)

    cooldown_up_in(5 * 60)

    buff_expires_in(30)
  end

  def clear_buff
    super
    dmg = random(207,279) * @buff_count

    dmg *= @sim.player.magic_bonus_multiplier(:holy)

    attack = @sim.player.spell_table
    dmg *= @sim.player.crit_multiplier(:magic) if attack == :crit

    @sim.mob.deal_damage(:ancient_fury, attack, dmg)
    
    @buff_count = 0
    @pet_damage_event.kill if @pet_damage_event
    @pet_damage_event = nil
  end

  def reset
    super
    @pet_damage_event.kill if @pet_damage_event
    @pet_damage_event = nil
    @buff_count = 0
  end

  def pet_damage
    # From simulationcraft
    attack = @sim.player.autoattack_table(:crit_chance => 0.05, :miss_chance => 0.08, :dodge_dhance => 0.065)

    dmg = random(5500,7000) # Unconfirmed but close approx (from simulationcraft)

    case attack
      when :crit then dmg *= 2 # Unconfirmed TODO
      when :glancing then dmg = (dmg * random(67,83)/100)
    end

    # Current thinking is GoAK doesn't get any buffs but is affected by debuffs 
    dmg *= 1 - @sim.mob.damage_reduction_from_armor(@sim.player.level) # Unconfirmed
    dmg *= 1.04 if @sim.mob.debuff_physical_damage

    @sim.mob.deal_damage(:guardian_of_ancient_kings, attack, dmg)

    proc_ancient_power unless [:miss, :dodge].include?(attack)

    # Reports indicate GoAK is unaffected by heroism.
    # http://elitistjerks.com/f76/t110342-retribution_concordance_4_0_6_compliant/p36/#post1900689 
    @pet_damage_event = @sim.new_event(self, "pet_damage", 2) 
  end

  def proc_ancient_power
    @buff_count += 1 if active?
    @buff_count = 20 if @buff_count > 20
  end

  module AugmentPlayerStrength
    def total_strength_from_buffs_and_consumables 
      str = super
      str *= 1 + 0.01 * @guardian_of_ancient_kings.buff_count if @guardian_of_ancient_kings.active?

      str += @strength * 0.01 * @guardian_of_ancient_kings.buff_count if @guardian_of_ancient_kings.active?
 
      str.round
    end
  end

  module ProcAncientPower
    def use
      super
      unless [:miss, :dodge].include?(@attack)
        @sim.player.guardian_of_ancient_kings.proc_ancient_power
      end
    end
  end

end
