class WordOfGlory < Ability
  attr_reader :buff_count
  
  def initialize(sim) 
    super(sim)

    @sim.player.extend(SelflessHealer)
  end

  def use
    raise "Error" unless usable?
    
    clear_buff
    
    if @sim.player.divine_purpose.active?
      @sim.player.divine_purpose.clear_buff if random > 0.3
      @buff_count = 3
    else
      @buff_count = @sim.player.holy_power
      @sim.player.holy_power = 0 if random > 0.3
    end

    buff_expires_in(10)

    @sim.mob.deal_damage(:word_of_glory, :hit, 0) # Just to count them 
    @sim.player.lock_gcd(:hasted => true)
  end


  def usable?
    @sim.player.has_holy_power and super
  end

  module SelflessHealer
    def physical_bonus_multiplier
      bonus = super
      bonus *= 1 + 0.04 * @word_of_glory.buff_count if @word_of_glory.active?
      bonus
    end

    def magic_bonus_multiplier(magic_type = :holy)
      bonus = super(magic_type)
      bonus *= 1 + 0.04 * @word_of_glory.buff_count if @word_of_glory.active?
      bonus
    end
  end
end
