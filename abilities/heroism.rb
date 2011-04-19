class Heroism < Ability
  
  def initialize(sim)
    super(sim)
    @sim.player.extend(HeroismHasteModifier)
  end

  def use
    raise "Error" unless usable? 

    cooldown_up_in(10 * 60)
    
    buff_expires_in(40)
  end

  def usable?
    super(:on_gcd => false)
  end

  module HeroismHasteModifier
    def calculated_haste(type = :physical)
      haste = super(type)
      haste += 30 if @heroism.active?
      haste
    end
  end

end
