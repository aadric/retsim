class GuardianOfAncientKings < Ability
  # Basic testing shows following:
  # 1. Damage unaffected by player stats
  # 2. Pet misses and dodges a lot, even when player is capped
  # 3. Pet can crit even when player can't melee crit
  # 4. Armor debuff doesn't increase damage
  #
  # Pet is also very bad about standing behind target dummys
  # but doesn't seem to have this problem on bosses, so I'm not accounting
  # for any parries or blocks.

  attr_reader :buff_count
  
  def initialize(player, mob)
    super(player, mob)
    @active = false
    @buff_count = 0

    @player.extend(AugmentPlayerStrength)
    @player.crusader_strike.extend(ProcAncientPower)
  end
  
  def use
    @active = true

    # Realistically, the pet doesn't hit right away
    @pet_damage_event = Event.new(self, "pet_damage", 0.1)

    cooldown_up_in(5 * 60)

    buff_expires_in(30)
  end

  def clear_buff
    super
    dmg = random(207,279) * @buff_count

    dmg *= @player.magic_bonus_multiplier(:holy)

    attack = @player.spell_table
    dmg *= @player.crit_multiplier(:magic) if attack == :crit

    @mob.deal_damage(:ancient_fury, attack, dmg)
    
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
    attack = @player.autoattack_table(:crit_chance => 0.05, :miss_chance => 0.08, :dodge_dhance => 0.065)

    dmg = random(5500,7000) # Unconfirmed but close approx

    case attack
      when :crit then dmg *= 2 # Unconfirmed
      when :glancing then dmg = (dmg * random(67,83)/100)
    end

    # TODO
    dmg *= 1.03 if @player.buff_damage

    dmg *= 1 - @mob.damage_reduction_from_armor(@player.level) # Unconfirmed

    @mob.deal_damage(:guardian_of_ancient_kings, attack, dmg)

    proc_ancient_power unless [:miss, :dodge].include?(attack)

    @pet_damage_event = Event.new(self, "pet_damage", 2) # TODO see if this is affected by buffs
  end

  def proc_ancient_power
    @buff_count += 1 if @active
    @buff_count = 20 if @buff_count > 20
  end

  module AugmentPlayerStrength
    def strength_from_buffs_and_consumables
      str = super
      str *= 1 + 0.01 * @guardian_of_ancient_kings.buff_count
      str += @strength * 0.01 * @guardian_of_ancient_kings.buff_count
      str.round
    end
  end

  module ProcAncientPower
    def use
      super
      unless [:miss, :dodge].include?(@last_attack)
        @player.guardian_of_ancient_kings.proc_ancient_power
      end
    end
  end

end
