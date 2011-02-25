class Player
  include CombatConstants
  attr_accessor :mob, :level, :race

  # state of player
  attr_accessor :is_gcd_locked,
                :holy_power             # 0,1,2,3

  # combat ratings and attributes from paper doll
  attr_accessor :hit_rating, :strength, :agility, :attack_power,
                :haste_rating, :crit_rating, :intellect, :expertise_rating

  # weapon stats exactly as they appear on weapon (NOT paper doll)
  attr_accessor :weapon_speed, :weapon_dmg_low_end, :weapon_dmg_high_end

  # buffs
  attr_accessor :buff_stats,                  # 5% stats, Blessing of Kings, Mark of the Wild, etc
                :buff_crit,                   # 5% crit, Leader of the Pack, Elemental Oath, etc
                :buff_damage,                 # 3% damage, Communion (not assumed)
                :buff_spell_haste,            # 5% speall haste, Warth of Air Totem, Boomkin, etc
                :buff_spell_power_major,      # 10% spell power, Totemic Wrath, Demonic Pact
                :buff_spell_power_minor,      # 6%, Arcane Brilliance, Flame Tongue Totem, etc
                :buff_physical_haste,         # 10% weapon speed, Windfury Totem, Icy Talons, etc
                :buff_attack_power,           # 10% attack power, Blessing of Might, Trueshot Aura, etc
                :buff_strength_and_agility    # Horn of Winter, Strength of Earth Totem, etc

  attr_accessor :seal # :seal_of_truth

  # consumables
  attr_accessor :flask_of_titanic_strength,
                :strength_from_food

  # glyphs
  attr_accessor :glyph_of_seal_of_truth,
                :glyph_of_exorcism,
                :glyph_of_crusader_strike

  attr_accessor :plate_specialization   # true / false

  # talents
  attr_accessor :talent_communion,                # true / false
                :talent_seals_of_the_pure,        # 0,1,2
                :talent_inquiry_of_faith,         # 0,1,2,3
                :talent_seals_of_command,         # true / false
                :talent_crusade,                  # 0,1,2,3
                :talent_rule_of_law,              # 0,1,2,3
                :talent_sanctity_of_battle,       # true / false
                :talent_blazing_light,            # 0,1,2
                :talent_art_of_war                # 0,1,2,3


  # TODO profession bonuses

  # temporary buffs
  attr_accessor :inquisition, :avenging_wrath, :heroism

  # abilities
  attr_accessor :crusader_strike, :exorcism

  def initialize(mob)
    @mob = mob  
    @level = 85
    @strength_from_food = 0
    @holy_power = 0
    
    # Paper Doll
    @strength = 506
    @agility = 94 
    @intellect = 106

    @attack_power = 1247
    @expertise_rating = 0
    @hit_rating = 0
    @crit_rating = 137
    @haste_rating = 0
    
    @talent_communion = true
    @race = :draenei
    @plate_specialization = false 
    @seal = :seal_of_truth
    @talent_seals_of_the_pure = 2
    @talent_inquiry_of_faith = 3
    @talent_seals_of_command = true

    # abilities
    @crusader_strike = CrusaderStrike.new(self, @mob)
    @exorcism = Exorcism.new(self, @mob)
    @buff_damage = true

    @glyph_of_exorcism = true

    @talent_art_of_war = 3
  end

  def calculated_attack_power
    ap = @attack_power
    ap += 2 * strength_from_buffs_and_consumables
    ap *= 1.10 if @buff_attack_power
    ap
  end

  def calculated_strength
    @strength + strength_from_buffs_and_consumables
  end

  # returns strength from buffs and consumables
  def strength_from_buffs_and_consumables
    str = 0

    str += 549 if @buff_strength_and_agility
    str += 300 if @flask_of_titanic_strength    
    str += @strength_from_food

    str *= 1.05 if @plate_specialization
    str *= 1.05 if @buff_stats
    str += @strength * 0.05 if @buff_stats
    return str
  end

  def clear
    @casting = false
    @swinging = false
  end

  def clear_gcd(time)
    @is_gcd_locked = false
  end

  def clear_swing_timer(time)
    @swing_on_cooldown = false
  end


  # Returns weapon damage at this exact moment
  def weapon_damage
    dmg = calculated_attack_power / 14
    dmg *= @weapon_speed

    dmg += random(@weapon_dmg_low_end, @weapon_dmg_high_end)
  end

  # Swing our weapon, doing damage instantly and creating an event when swing timer is up
  def swing(current_time)
    dmg = weapon_damage
    
    attack = attack_table(:autoattack)

    if [:hit, :crit, :glancing].include?(attack)
      # Seal of truth can't miss, be dodged, or glance.
      # It crits independently
      if @seal == :seal_of_truth
        # Damage is based on number of stacks immediately before hit
        seal_of_truth_dmg(dmg)
        if @mob.censure_stacks == 0
          # Create event to proc censure
          setup_next_censure_tick(current_time)
        end
        if @mob.censure_stacks < 5
          # This is cheating as censure actually has a chance to miss 
          # based on spell hit.
          @mob.censure_stacks = @mob.censure_stacks + 1
        end
      end

      seals_of_command_dmg(dmg) if @talent_seals_of_command
    end



    case attack 
      when :miss then dmg = 0
      when :dodge then dmg = 0
      when :crit then dmg *= 2 # TODO meta gem
      # No one knows how glancing blows work.  Basic testing shows an average of 25% reduction
      # However its not a static value.
      # This falls in line with limited testing (500 swings)
      when :glancing then dmg = (dmg * random(67,83)/100).round
    end  


    # calculate physical bonus %
    # from 4% buff
    # does 4% stack with communion multiplicty or additively?

    # from 3% damage buff
    dmg *= 1.03 if @buff_damage

    # from communion
    dmg *= 1.02 if @talent_communion

    # two handed bonus from just being ret
    dmg *= 1.2

    # augment damage by mobs armor
    dmg *= 1 - @mob.damage_reduction_from_armor(@level)
     

    # is aw up?
    dmg *= 1.2 if @avenging_wrath


    dmg = dmg.round
    Statistics.instance.log_damage_event(:melee, attack, dmg)
    
    swing_speed = @weapon_speed / (1 + calculated_haste(:physical) / 100)
    event = Event.new(self, "swing", current_time + swing_speed * 1000)
    
    if @talent_art_of_war and [:hit, :crit, :glancing].include?(attack)
      proc_chance = [0.20, 0.07 * @talent_art_of_war].min # 0.00, 0.07, 0.14, 0.20
      @exorcism.proc_art_of_war(current_time) if random < proc_chance
    end
  end

  def censure_dot_damage(current_time)
    if(@mob.censure_stacks <= 0 or @mob.censure_stacks > 5)
      # This shouldn't ever happen
      raise "Censure Stack Error"
    end

    dmg = 0.0192 * calculated_attack_power
    dmg += 0.01 * calculated_spell_power
    dmg *= @mob.censure_stacks

    dmg *= magic_bonus_multiplier(:holy)

    percent_bonus = @talent_inquiry_of_faith * 0.1 
    percent_bonus += 0.06 * @talent_seals_of_the_pure if @talent_seals_of_the_pure
    multiplier = 1 + percent_bonus
    dmg *= multiplier

    dmg *= 1.2 if @avenging_wrath


    attack = :hit
    if random < melee_crit_chance
      dmg *= crit_multiplier(:physical)
      attack = :crit
    end

    Statistics.instance.log_damage_event(:censure, attack, dmg.round)
    setup_next_censure_tick(current_time)
  end

  def setup_next_censure_tick(current_time)
    # http://www.tentonhammer.com/wow/guides/stats/haste-hots-dots
    # http://elitistjerks.com/f80/t112939-affliction_cataclysm_%7C_dots_you_4_0_6_updated/#Haste
    # new tick = base tick / (1 + haste %)
    next_tick = 3 / (1 + calculated_haste(:magic) / 100) # in seconds
    event = Event.new(self, "censure_dot_damage", current_time + next_tick * 1000)
  end

  # returns haste in % for either melee or spells
  def calculated_haste(type = :physical)
    raise "Wrong parameters for calculated_haste" unless [:physical, :magic].include?(type) # in case I accidently try to pass :melee or :spell
    haste = @haste_rating / 128.05701 
    haste += 0.03 * @talent_judgements_of_the_pure if @talent_judgements_of_the_pure
    haste += 0.05 if @buff_spell_haste and type == :magic
    haste += 0.10 if @buff_melee_haste and type == :physical
    haste += 0.30 if @temporary_buff_heroism
    return haste
  end

  # Spell power from tooltip at this exact moment in time
  def calculated_spell_power
    sp = @intellect - 10
    sp += calculated_attack_power * 0.3 
    sp *= 1.1 if @buff_spell_power_major
    return sp
  end

  def swing_off_cooldown(time)
    @is_on_swing_cooldown = false
  end

  def magic_bonus_multiplier(magic_type = :holy)
    percent = @talent_communion ? 0.02 : 0
    percent += 0.03 if @buff_damage # TODO find out why this is additive, should be easy to check
    multiplier = 1 + percent
    multiplier *= 1.08 if @mob.debuff_spell_damage
    multiplier *= 1.3 if @inquisition and magic_type == :holy
    return multiplier
  end 

  def physical_bonus_multiplier
    percent = @talent_communion ? 0.02 : 0
    percent += 0.04 if @mob.debuff_physical_damage
    multiplier = 1 + percent
    multiplier *= 1.03 if @buff_damage # TODO why is this multiplicative here and additve in magic?
    return multiplier
  end


  def seals_of_command_dmg(weapon_dmg)
    dmg = 0.07 * weapon_dmg
    dmg *= magic_bonus_multiplier(:holy)
    dmg *= 1.2 # two handed specialization
    dmg *= 1.2 if @avenging_wrath

    # Seals of Command can miss and can be dodged, but can't be a glancing blow
    attack = attack_table(:special)

    case attack
      when :crit then dmg *= 2 
      when :miss then dmg = 0
      when :dodge then dmg = 0
    end
    
    Statistics.instance.log_damage_event(:seals_of_command, attack, dmg.round)

  end

  def seal_of_truth_dmg(weapon_dmg)
    return if @mob.censure_stacks == 0 

    # Seal of Truth has a very poor tooltip
    # Seems to deal 3% weapon damage per stack
    dmg = (@mob.censure_stacks * 0.03)
    dmg *= weapon_dmg

    dmg *= magic_bonus_multiplier(:holy)

    dmg *= 1.12 if @talent_seals_of_the_pure

    # two handed specialization
    dmg *= 1.2 

    attack = :hit

    # Seal of truth can't miss, be dodged, or glance 
    if random < melee_crit_chance
      dmg *= crit_multiplier(:physical)
      attack = :crit
    end

    Statistics.instance.log_damage_event(:seal_of_truth, :hit, dmg.round)
  end

  def melee_miss_chance
    # TODO replace with mob base hit _chance
    melee_miss_chance = 0.08
    # TODO replace with constant
    melee_miss_chance -= @hit_rating / 120.109 / 100
    melee_miss_chance -= 0.01 if @race == :draenei
    return [melee_miss_chance, 0].max
  end

  def melee_dodge_chance
    melee_dodge_chance = 0.065
    melee_dodge_chance -= 0.025 if @seal == :seal_of_truth and @glyph_of_seal_of_truth
    melee_dodge_chance -= @expertise_rating / 120.109 / 100
    return [melee_dodge_chance,0].max
  end

  def melee_crit_chance
    melee_crit_chance = 0.00652
    melee_crit_chance += @crit_rating / 179.28 / 100
    melee_crit_chance += calculated_agility / 203.08 / 100
    melee_crit_chance -= 0.048
  end

  # This can return less than 0. This allows other abilities to correctly calculate their crit
  # chance at very low levels of crit.
  def spell_crit_chance
    spell_crit_chance = 0.033355
    spell_crit_chance += 0.05 if @buff_crit
    spell_crit_chance += 0.05 if @mob.debuff_spell_crit
    spell_crit_chance += @crit_rating / 179.28 / 100
    spell_crit_chance -= 0.021
  end

  def spell_miss_chance
    miss_chance = 0.17
    miss_chance -= @hit_rating / 102.446 / 100
    miss_chance -= 0.01 if @race == :draenei
    miss_chance -= 0.08 
  end

  # Calculates crit multiplier for physical or magical attacks
  def crit_multiplier(type = :physical)
    raise "Wrong parameters for crit_multiplier" unless [:physical, :magic].include?(type) # in case I accidently try to pass :melee

    multiplier = type == :physical ? 2 : 1.5
    multiplier *= 1.03 if @crit_meta_gem
    multiplier
  end

  def attack_table(type = :autoattack, crit_chance = nil)
    attack = random
    
    crit_chance = melee_crit_chance unless crit_chance

    # Everyone's best guess is glancing blows are 24%, but might be 25% needs
    # more testing
    if(type == :autoattack) 
      if(attack < 0.24) then return :glancing else attack -= 0.24 end
    end
    if(attack < melee_miss_chance) then return :miss else attack -= melee_miss_chance end
    if(attack < melee_dodge_chance) then return :dodge else attack -= melee_dodge_chance end
    if(attack < crit_chance) then return :crit end
    return :hit
  end

  def spell_table(crit_chance = nil)
    attack = random
    
    crit_chance = spell_crit_chance unless crit_chance

    if(attack < spell_miss_chance) then return :miss else attack -= spell_miss_chance end
    if(attack < crit_chance) then return :crit end
    return :hit
  end

  def calculated_agility
    return @agility
  end


  def output_stats()
    left_spacing = 25
    puts "Agility".ljust(left_spacing) + @agility.to_s
    puts "Melee Crit Chance".ljust(left_spacing) + melee_crit_chance.to_s
    puts "Melee Miss Chance".ljust(left_spacing) + melee_miss_chance.to_s
    puts "Melee Dodge Chance".ljust(left_spacing) + melee_dodge_chance.to_s
    puts "Calculated Attack Power".ljust(left_spacing) + calculated_attack_power.to_s
    puts "Calculated Strength".ljust(left_spacing) + calculated_strength.to_s
    puts "Armor Reduction".ljust(left_spacing) + @mob.damage_reduction_from_armor(@level).to_s
  end
end
