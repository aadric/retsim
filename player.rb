class Player
  include CombatConstants
  attr_accessor :level, :race

  # state of player
  attr_accessor :holy_power             # 0,1,2,3

  # combat ratings and attributes from paper doll, without any buffs
  attr_accessor :hit_rating, :strength, :agility, :attack_power,
                :haste_rating, :crit_rating, :intellect, :expertise_rating,
                :mastery_rating

  # weapon stats exactly as they appear on weapon
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

  attr_accessor :seal # Which seal are we using.  :seal_of_truth

  # consumables
  attr_accessor :flask_of_titanic_strength,
                :strength_from_food

  # glyphs
  attr_accessor :glyph_of_seal_of_truth, :glyph_of_exorcism, :glyph_of_judgement,
                :glyph_of_templars_verdict,:glyph_of_crusader_strike, :glyph_of_consecration

  attr_accessor :plate_specialization, :two_handed_specialization   # true / false

  # talents
  attr_accessor :talent_communion,                # true / false
                :talent_seals_of_the_pure,        # 0,1,2
                :talent_sanctified_wrath,         # 0,1,2,3
                :talent_inquiry_of_faith,         # 0,1,2,3
                :talent_seals_of_command,         # true / false
                :talent_crusade,                  # 0,1,2,3
                :talent_rule_of_law,              # 0,1,2,3
                :talent_sanctity_of_battle,       # true / false
                :talent_blazing_light,            # 0,1,2
                :talent_judgements_of_the_pure,   # 0,1,2,3
                :talent_arbiter_of_the_light,     # 0,1,2
                :talent_divine_purpose,           # 0,1,2
                :talent_art_of_war                # 0,1,2,3

  # Set Bonuses
  attr_accessor :set_bonus_t11_two_piece,  # true / false
                :set_bonus_t11_four_piece  # We DO NOT assume two piece just because four piece is there

  attr_accessor :crit_meta_gem # true / false


  # TODO profession bonuses

  # abilities
  attr_reader :crusader_strike, :exorcism, :templars_verdict, :holy_wrath, :hammer_of_wrath,
              :judgement, :divine_purpose, :zealotry, :avenging_wrath,
              :guardian_of_ancient_kings, :autoattack, :seal_of_truth, :inquisition, :heroism,
              :consecration, :word_of_glory

  attr_reader :abilities, :augmentations

  def initialize(sim)
    @sim = sim
    sim.player = self
    @holy_power = 0

    # abilities
    # TODO automate this
    @abilities = []
    @abilities << @autoattack = AutoAttack.new(sim)
    @abilities << @crusader_strike = CrusaderStrike.new(sim)
    @abilities << @exorcism = Exorcism.new(sim)
    @abilities << @templars_verdict = TemplarsVerdict.new(sim)
    @abilities << @holy_wrath = HolyWrath.new(sim)
    @abilities << @hammer_of_wrath = HammerOfWrath.new(sim)
    @abilities << @judgement = Judgement.new(sim)
    @abilities << @inquisition = Inquisition.new(sim)
    @abilities << @word_of_glory = WordOfGlory.new(sim)

    @abilities << @zealotry = Zealotry.new(sim)
    @abilities << @avenging_wrath = AvengingWrath.new(sim)
    @abilities << @divine_purpose = DivinePurpose.new(sim) 
    @abilities << @guardian_of_ancient_kings = GuardianOfAncientKings.new(sim)
    @abilities << @seal_of_truth = SealOfTruth.new(sim)
    @abilities << @heroism = Heroism.new(sim)
    @abilities << @consecration = Consecration.new(sim)

    @procs = []

    # Stat changes we make for the purposes of testing (ie calculating stat weights)
    # Negative numbers not necesarily safe (but probably are if you're using full gear)
    @augmentations = Hash.new(0)
  end

  def reset
    @holy_power = 0
    clear_gcd
    
    @abilities.each do |ability|
      ability.reset
    end

    @procs.each do |proc|
      proc.reset
    end

    clear_trinket_lockout
  end

  def proc=(proc_sym)
    @procs << Kernel.const_get(proc_sym.to_s.camelize).new(@sim) 
  end

  alias :trinket= :proc=
  alias :enchant= :proc=

  def calculated_attack_power
    ap = attack_power + @augmentations[:attack_power]
    ap += 2 * total_strength_from_buffs_and_consumables
    ap *= 1.10 if buff_attack_power
    ap.round
  end

  def calculated_strength
    strength + total_strength_from_buffs_and_consumables
  end

  def calculated_intellect
    intellect + intellect_from_buffs_and_consumables
  end

  def total_strength_from_buffs_and_consumables
    str = additive_strength_from_buffs_and_consumables

    str *= 1.05 if plate_specialization
    str *= 1.05 if buff_stats

    str += strength * 0.05 if buff_stats
    return str.round
  end

  # returns strength from buffs and consumables
  def additive_strength_from_buffs_and_consumables
    str = 0

    str += @augmentations[:strength]

    str += 549 if buff_strength_and_agility
    str += 300 if flask_of_titanic_strength    
    str += strength_from_food

    return str
  end

  def intellect_from_buffs_and_consumables
    int = 0
    
    int += intellect * 0.05 if buff_stats
    return int.round
  end

  def clear
    @casting = false
  end

  def clear_gcd
    @gcd_lock.kill if @gcd_lock
    @gcd_lock = nil
  end
  
  def gcd_locked?
    @gcd_lock==nil ? false : true
  end

  def lock_gcd(params = {})
    raise "You are already locked" if gcd_locked?
    params[:hasted] ||= false
    duration = params[:hasted] ? hasted_cast : GLOBAL_COOLDOWN
    @gcd_lock = @sim.new_event(self, "clear_gcd", duration)
  end

  def gcd_remaining
    return 0 unless @gcd_lock
    return (@gcd_lock.time - @sim.runner.current_time) / 1000
  end

  # Returns weapon damage at this exact moment
  def weapon_damage(options = {})
    options[:normalized] ||= false

    dmg = calculated_attack_power / 14.to_f
    dmg = (dmg * 10).round / 10.to_f
    dmg *= options[:normalized] ? 3.3 : weapon_speed

    dmg += random(weapon_dmg_low_end, weapon_dmg_high_end)
  end

  # returns haste in % for either melee or spells
  def calculated_haste(type = :physical)
    raise "Wrong parameters for calculated_haste" unless [:physical, :magic].include?(type) # in case I accidently try to pass :melee or :spell
    haste = (haste_rating + @augmentations[:haste_rating]) / 128.05701 
    haste += 3 * talent_judgements_of_the_pure if talent_judgements_of_the_pure # TODO actually model this instead of cheating
    haste += 5 if buff_spell_haste and type == :magic
    haste += 10 if buff_physical_haste and type == :physical
    return haste
  end

  # Spell power from tooltip at this exact moment in time
  def calculated_spell_power
    sp = calculated_intellect - 10
    sp += calculated_attack_power * 0.3 
    sp *= 1.1 if buff_spell_power_major
    return sp.round
  end

  def magic_bonus_multiplier(magic_type = :holy)
    percent = talent_communion ? 0.02 : 0
    percent += 0.03 if buff_damage # TODO find out why this is additive, should be easy to check
    multiplier = 1 + percent
    multiplier *= 1.08 if @sim.mob.debuff_spell_damage
    return multiplier
  end 

  def physical_bonus_multiplier
    percent = talent_communion ? 0.02 : 0
    percent += 0.04 if @sim.mob.debuff_physical_damage
    multiplier = 1 + percent
    multiplier *= 1.03 if buff_damage # TODO why is this multiplicative here and additve in magic?
    return multiplier
  end

  def mastery_percent  
    val = 0.168
    val += (mastery_rating + @augmentations[:mastery_rating]) / 179.28 * 0.021
  end

  def melee_miss_chance
    # TODO replace with mob base hit_chance
    melee_miss_chance = 0.08
    # TODO replace with constant
    melee_miss_chance -= (hit_rating + @augmentations[:hit_rating]) / 120.109 / 100
    melee_miss_chance -= 0.01 if race == :draenei
    return [melee_miss_chance, 0].max
  end

  def melee_dodge_chance
    melee_dodge_chance = 0.065
    melee_dodge_chance -= 0.025 if seal == :seal_of_truth and glyph_of_seal_of_truth
    melee_dodge_chance -= (expertise_rating + @augmentations[:expertise_rating]) / 120.109 / 100
    return [melee_dodge_chance,0].max
  end

  def melee_crit_chance
    melee_crit_chance = 0.00652
    melee_crit_chance += 0.05 if buff_crit
    melee_crit_chance += (crit_rating + @augmentations[:crit_rating]) / 179.28 / 100
    melee_crit_chance += calculated_agility / 203.08 / 100
    melee_crit_chance -= 0.048
  end

  # This can return less than 0. This allows other abilities to correctly calculate their crit
  # chance at very low levels of crit.
  def spell_crit_chance
    spell_crit_chance = 0.033355
    spell_crit_chance += 0.05 if buff_crit
    spell_crit_chance += 0.05 if @sim.mob.debuff_spell_crit
    spell_crit_chance += (crit_rating + @augmentations[:crit_rating])  / 179.28 / 100
    spell_crit_chance -= 0.021
  end

  def spell_miss_chance
    miss_chance = 0.17
    miss_chance -= (hit_rating + @augmentations[:hit_rating]) / 102.446 / 100
    miss_chance -= 0.01 if race == :draenei
    miss_chance -= 0.08 
  end

  # Calculates crit multiplier for physical or magical attacks
  def crit_multiplier(type = :physical)
    raise "Wrong parameters for crit_multiplier" unless [:physical, :magic].include?(type) # in case I accidently try to pass :melee

    multiplier = type == :physical ? 2 : 1.5
    multiplier *= 1.03 if crit_meta_gem
    multiplier
  end

  def autoattack_table(options = {})
    options[:crit_chance] ||= melee_crit_chance
    options[:miss_chance] ||= melee_miss_chance
    options[:dodge_chance] ||= melee_dodge_chance
    attack = random

    # TODO confirm its 24% and not 25%
    if(attack < 0.24) then return :glancing else attack -= 0.24 end
    if(attack < options[:miss_chance]) then return :miss else attack -= options[:miss_chance] end
    if(attack < options[:dodge_chance]) then return :dodge else attack -= options[:dodge_chance] end
    if(attack < options[:crit_chance]) then return :crit end
    return :hit
  end

  def special_attack_table(options = {})
    options[:ranged] ||= false
    options[:crit_chance] ||= melee_crit_chance
    
    attack = random

    if(attack < melee_miss_chance) then return :miss else attack -= melee_miss_chance end
    unless options[:ranged]
      if(attack < melee_dodge_chance) then return :dodge end
    end

    # two roll system for specials
    attack = random
    if random < options[:crit_chance] then return :crit end
    return :hit
  end

  def spell_table(crit_chance = nil) # TODO change to options
    crit_chance = spell_crit_chance unless crit_chance

    if(random < spell_miss_chance) then return :miss end
    if(random < crit_chance) then return :crit end
    return :hit
  end

  def calculated_agility
    bonus_agility = 0
    bonus_agility += 549 if buff_strength_and_agility
    bonus_agility *= 1.05 if buff_stats
    bonus_agility += agility * 1.05 if buff_stats
    agility + bonus_agility
  end

  def hasted_cast(cast_time = 1.5)
    return cast_time / (1 + calculated_haste(:magic) / 100)
  end

  def has_holy_power(count=1)
    raise "Called has_holy_power with bad arguments" unless [1,2,3].include?(count)
    return (holy_power >= count or divine_purpose.active?)
  end

  def output_stats
    left_spacing = 25
    puts "Agility".ljust(left_spacing) + agility.to_s
    puts "Melee Crit Chance".ljust(left_spacing) + melee_crit_chance.to_s
    puts "Melee Miss Chance".ljust(left_spacing) + melee_miss_chance.to_s
    puts "Melee Dodge Chance".ljust(left_spacing) + melee_dodge_chance.to_s
    puts "Calculated Attack Power".ljust(left_spacing) + calculated_attack_power.to_s
    puts "Calculated Strength".ljust(left_spacing) + calculated_strength.to_s
    puts "Armor Reduction".ljust(left_spacing) + @sim.mob.damage_reduction_from_armor(@level).to_s
  end

  def use_trinkets
    @procs.each do |trinket|
      trinket.use
    end
  end

  def lockout_trinkets(seconds)
    raise "trinket lockout already in affect" if @trinket_lockout
    @trinket_lockout = @sim.new_event(self, "clear_trinket_lockout", seconds)
  end

  def clear_trinket_lockout
    @trinket_lockout.kill if @trinket_lockout
    @trinket_lockout = nil
  end

  def trinkets_locked?
    return @trinket_lockout ? true : false
  end
end
