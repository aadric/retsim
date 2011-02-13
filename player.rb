class Player
  include CombatConstants

  attr_accessor :lavel

  # state of player
  attr_accessor :is_gcd_locked, :is_on_swing_cooldown


  # combat ratings from paper doll
  attr_accessor :hit_rating, :strength, :attack_power, :haste_rating, :crit_rating, :intellect, :expertise_rating

  # weapon speed exactly as it appears on the tooltip (ex: 3.6)
  attr_accessor :weapon_speed

  # weapond damage exactly as it appears on tooltip
  attr_accessor :weapon_dmg_low_end, :weapon_dmg_high_end

  # buffs
  attr_accessor :strength_of_earth_totem, :blessing_of_kings, :attack_power_bonus

  # consumables
  attr_accessor :flask_of_titanic_strength, :strength_from_food

  # glyphs
  attr_accessor :glyph_of_seal_of_truth

  attr_accessor :plate_specialization

  # TODO profession bonuses

  # talents
  
  # temporary buffs
  attr_accessor :inquisition

  def initialize()
    @level = 85
    @strength_from_food = 0
  end

  def calculated_attack_power
    ap = @ap
    ap += 2 * strength_from_buffs_and_consumables
    ap *= 1.10 if @attack_power_bonus
    ap
  end

  def calculated_strength
    @strength + strength_from_buffs_and_consumables
  end

  # returns strength from buffs and consumables
  def strength_from_buffs_and_consumables
    str = 0

    str += 549 if @strength_of_earth_totem
    str += 300 if @flask_of_titanic_strength    
    str += @strength_from_food

    str *= 1.05 if @plate_specialization
    str *= 1.05 if @blessing_of_kings
    str += @strength * 0.05 if @blessing_of_kings
    str
  end

  def clear
    @casting = false
    @swinging = false
  end

  def clear_gcd(time)
    @gcd_locked = false
  end

  def clear_swing_timer(time)
    @swing_on_cooldown = false
  end

  # Swing our weapon, doing damage instantly and creating an event when swing timer is up
  def swing(current_time, mob)
    # calculate damage
    dmg = calculate_attack_power / 14
    dmg += random(@weapon_dmg_low_end, @weapon_dmg_high_end)

    # augment damage by communion

    # augment damage by mobs armor
    
    # two handed bonus from just being ret

    # is aw up?
  end
end
